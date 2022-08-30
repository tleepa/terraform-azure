data "azurerm_resource_group" "lz_rg" {
  name = "${var.prefix}-${terraform.workspace}-lz"
}

data "azurerm_virtual_network" "lz_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = data.azurerm_resource_group.lz_rg.name
}

data "azurerm_subnet" "subnet_prv" {
  name                 = "subnet_prv"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_rg.name
}

data "azurerm_subnet" "subnet_pub" {
  name                 = "subnet_pub"
  virtual_network_name = data.azurerm_virtual_network.lz_vnet.name
  resource_group_name  = data.azurerm_resource_group.lz_rg.name
}
