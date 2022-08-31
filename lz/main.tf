provider "azurerm" {
  features {}
}

data "http" "ext_ip" {
  url = "https://ipinfo.io/ip"
}

resource "azurerm_resource_group" "lz_rg" {
  name     = "${var.prefix}-${terraform.workspace}-lz"
  location = var.region
}

resource "azurerm_network_security_group" "nsg_pub" {
  name                = "${var.prefix}-nsg-pub"
  location            = azurerm_resource_group.lz_rg.location
  resource_group_name = azurerm_resource_group.lz_rg.name

  security_rule {
    name                       = "allow-in-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = data.http.ext_ip.response_body
    destination_address_prefix = var.subnet_pub
  }
}

resource "azurerm_network_security_group" "nsg_prv" {
  name                = "${var.prefix}-nsg-prv"
  location            = azurerm_resource_group.lz_rg.location
  resource_group_name = azurerm_resource_group.lz_rg.name
}

resource "azurerm_virtual_network" "lz_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.lz_rg.name
  location            = azurerm_resource_group.lz_rg.location
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "subnet_pub" {
  name                 = "subnet_pub"
  resource_group_name  = azurerm_resource_group.lz_rg.name
  virtual_network_name = azurerm_virtual_network.lz_vnet.name
  address_prefixes     = [var.subnet_pub]
}

resource "azurerm_subnet" "subnet_prv" {
  name                 = "subnet_prv"
  resource_group_name  = azurerm_resource_group.lz_rg.name
  virtual_network_name = azurerm_virtual_network.lz_vnet.name
  address_prefixes     = [var.subnet_prv]
}

resource "azurerm_subnet_network_security_group_association" "subnet_pub" {
  subnet_id                 = azurerm_subnet.subnet_pub.id
  network_security_group_id = azurerm_network_security_group.nsg_pub.id
}

resource "azurerm_subnet_network_security_group_association" "subnet_prv" {
  subnet_id                 = azurerm_subnet.subnet_prv.id
  network_security_group_id = azurerm_network_security_group.nsg_prv.id
}

resource "azurerm_private_dns_zone" "prv_zone" {
  name                = "${var.prefix}-${terraform.workspace}.local"
  resource_group_name = azurerm_resource_group.lz_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${azurerm_virtual_network.lz_vnet.name}-link"
  resource_group_name   = azurerm_resource_group.lz_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.prv_zone.name
  virtual_network_id    = azurerm_virtual_network.lz_vnet.id
  registration_enabled  = true
}
