output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "alb_public_ip" {
  value = azurerm_public_ip.alb_ip.ip_address
}