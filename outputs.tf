output "network_interface_private_ip" {
  description = "Private ip addresses of the VM NICs"
  value       = azurerm_network_interface.vm_nix.*.private_ip_address
}

output "azurerm_virtual_machine" {
  description = "Hostnames of created VMs"
  value       = azurerm_virtual_machine.vm.*.name
}

