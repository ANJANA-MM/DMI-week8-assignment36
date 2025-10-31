variable "location" {
  description = "location of the resources"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
}

variable "subnet_prefix" {
  description = "Subnet address prefix"
}

variable "public_ip_sku" {
  description = "SKU for Public IPs"
}

variable "admin_username" {
  description = "Username for SSH login to the VMs"
}

