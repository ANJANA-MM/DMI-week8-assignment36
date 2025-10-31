# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

# Configure resource group
resource "azurerm_resource_group" "minif_rg" {
  name     = "minif-rg"
  location = var.location
}

# Configure Virtual Network
resource "azurerm_virtual_network" "minif_vnet" {
  name                = "minif-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.minif_rg.location
  resource_group_name = azurerm_resource_group.minif_rg.name
}

# Configure subnet for vm
resource "azurerm_subnet" "minif_sn" { 
  name                 = "minif-sn"
  resource_group_name  = azurerm_resource_group.minif_rg.name
  virtual_network_name = azurerm_virtual_network.minif_vnet.name
  address_prefixes     = var.subnet_prefix
}

# Configure public ip 
resource "azurerm_public_ip" "minif_public_ip" {
  name                = "vm-public-ip"
  resource_group_name = azurerm_resource_group.minif_rg.name
  location            = azurerm_resource_group.minif_rg.location
  allocation_method   = "Static"
  sku                 = var.public_ip_sku
}

# Configure Network Interface
resource "azurerm_network_interface" "minif_nic" {
  name                = "minif-nic"
  location            = azurerm_resource_group.minif_rg.location
  resource_group_name = azurerm_resource_group.minif_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.minif_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.minif_public_ip.id
  }
}

# Configure Network Security Group
resource "azurerm_network_security_group" "minif_nsg" {
  name                = "minif-nsg"
  location            = azurerm_resource_group.minif_rg.location
  resource_group_name = azurerm_resource_group.minif_rg.name

  # SSH rule
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP rule
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associates a Network Security Group with the Subnet within the Virtual Network
resource "azurerm_subnet_network_security_group_association" "minif_nsg_assoc" {
  subnet_id                 = azurerm_subnet.minif_sn.id
  network_security_group_id = azurerm_network_security_group.minif_nsg.id
}

# Create vm
resource "azurerm_linux_virtual_machine" "minif_vm" {
  name                = "minif-vm"
  resource_group_name = azurerm_resource_group.minif_rg.name
  location            = azurerm_resource_group.minif_rg.location
  size                = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.minif_nic.id
  ]
  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

