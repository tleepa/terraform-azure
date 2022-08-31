output "subnet_pub_id" {
  value = azurerm_subnet.subnet_pub.id
}

output "subnet_prv_id" {
  value = azurerm_subnet.subnet_prv.id
}

output "res_location" {
  value = azurerm_resource_group.lz_rg.location
}

output "private_domain" {
  value = azurerm_private_dns_zone.prv_zone.name
}
