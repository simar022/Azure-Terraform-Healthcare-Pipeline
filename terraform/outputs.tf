output "vm_ssh_public_ip" {
  value       = azurerm_public_ip.vm_ssh_ip.ip_address
  description = "Use this IP to SSH into the VM"
}

output "app_alb_public_ip" {
  value       = azurerm_public_ip.alb_ip.ip_address
  description = "Public URL for the App"
}