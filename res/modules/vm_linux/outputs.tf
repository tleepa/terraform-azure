output "hostname" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "public_name" {
  value = var.public_ip == true ? data.azurerm_public_ip.jb_ip[0].fqdn : ""
}
