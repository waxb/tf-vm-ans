resource "azurerm_public_ip" "vm-pip" {
  name                = "vm-pip${count.index + 1}"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  count               = var.vm_count
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix     = "10.0.2.0/24"
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
    subnet_id                               = azurerm_subnet.example.id
    private_ip_address_allocation           = "Dynamic"
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
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0mWt2+WDL7xhv3jP6J+rb/eYBrRkYPFw9mVMoaCme0GB6YivQItfTtrtqcMcAOlF0BVvNFSIaDnVPX4zy7svy7NHcbMJkf2DEFZip3QijArQQRdq1fLWvYyNh6m/MBPrLDOeXDLzw+PI9mZpAAtfAsoJltSk396M9cv3Ae/79BuRiutjc8YTocAabrPG+yG+IjB/Dv3mqe6rDZNWyh3NhiNCFZ7a+pHI5RJA+RURNWgDR4rKr53p1/XNmCAqDY2rD1DVck/gvhw72R1pVucHYdVVpwGdAtvMhGKC/eVxu+8vfW9lopSuZ7WryAU0H014kKXy7SZSZs9xrTB/KlMR5/kJRW/8MIrgA8ltPnBhE1ouH0HxfImOlph9upDcOkqAGrLxiphYG9phtR7nu4yZ1jWqICFA7+2sWJF1f8rtYcneD58EcwUnJ8wMB/DLxJiEaWlog2beKRhZsZ/2d5J9XFJv7SZLdSECONAu+YT5ZE+Mi6y5hThdP2LuRmt0n4aE=" #should not be here but doesn't matter for now
    }
  }
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
    servers = join("\n", azurerm_public_ip.vm-pip.*.ip_address)
  }
}

resource "null_resource" "ansible" {
  triggers = {
    template_rendered = data.template_file.inventory.rendered
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' >> inventory && export INV='${data.template_file.inventory.rendered}'" #&& echo '${data.template_file.inventory.rendered}' >> ../../../inventory"
  }
}
