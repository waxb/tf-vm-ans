resource "azurerm_public_ip" "vm-pip" {
  name                = "vm-pip${count.index + 1}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  count               = var.vm_count
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "${var.vm_prefix}_datadisk${count.index + 1}"
  location             = var.location
  resource_group_name  = var.rg_name
  storage_account_type = var.stg_acc_type
  disk_size_gb         = var.data_disk_size
  count                = format("%d", var.data_disk_count * var.vm_count)
  create_option = "Empty"

  encryption_settings {
  	enabled           	= var.encrypted
  	disk_encryption_key {
  		secret_url      = var.secret_url
  		source_vault_id = var.source_vault_id
  	}
  	key_encryption_key {
  		key_url         = var.key_url
  		source_vault_id = var.source_vault_id
  	}
  }
}

resource "azurerm_network_interface" "vm_nix" {
  name                = "${var.vm_prefix}_nic${count.index + 1}"
  location            = var.location
  resource_group_name = var.rg_name

  network_security_group_id = var.network_security_group_id
  count = var.vm_count

  ip_configuration {
    name                                    = "${var.vm_prefix}_ipconf${count.index + 1}"
    public_ip_address_id                    = element(azurerm_public_ip.vm-pip.*.id, count.index)
    load_balancer_backend_address_pools_ids = [var.backend_pool_id]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vm_prefix}0${count.index + 1}"
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [element(azurerm_network_interface.vm_nix.*.id, count.index)]
  vm_size               = var.vm_size
  count                 = var.vm_count

  delete_os_disk_on_termination    = var.dosdisk
  delete_data_disks_on_termination = var.ddadisk

  availability_set_id               = var.availability_set_id

  storage_os_disk {
    name              = "${var.vm_prefix}_disk${count.index + 1}"
    managed_disk_type = var.os_acc_type

    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.im_version
  }

  os_profile {
    computer_name  = "${var.vm_prefix}0${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_keys
    }
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachddisks" {
  managed_disk_id = element(azurerm_managed_disk.data_disk.*.id, count.index)
  virtual_machine_id = element(
    azurerm_virtual_machine.vm.*.id,
    format("%d", count.index % var.vm_count),
  )
  lun     = "1${format("%d", count.index / var.vm_count)}"
  caching = "ReadWrite"

  count = format("%d", var.data_disk_count * var.vm_count)
}

data "template_file" "inventory" {
  template = file("${path.module}/templates/ansible_inv.tpl")

  depends_on = [
    azurerm_virtual_machine.vm,
    azurerm_network_interface.vm_nix,
  ]

  vars = {
    ansvars = "[${var.group_name}:vars]\nansible_user = ${var.admin_username}"
    group   = "[${var.group_name}]"
    servers = join("\n", azurerm_network_interface.vm_nix.*.private_ip_address)
  }
}

resource "null_resource" "ansible" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' >> inventory"
  }
}
