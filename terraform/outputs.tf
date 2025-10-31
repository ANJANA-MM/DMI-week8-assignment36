# Public IPs of created VMs
output "vm_public_ip" {
  value = azurerm_public_ip.minif_public_ip.ip_address
}

