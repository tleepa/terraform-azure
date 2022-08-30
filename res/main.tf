provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "${var.prefix}-${terraform.workspace}-res"
  location = var.region
}

data "local_file" "ssh_pub_key" {
  filename = "${var.ssh_key_path}/${terraform.workspace}.pub"
}

module "bastion" {
  source   = "./modules/vm_linux"
  for_each = local.jbs

  count_index = each.key
  size        = can(each.value.size) ? each.value.size : ""
  rg_name     = azurerm_resource_group.vm_rg.name
  region      = azurerm_resource_group.vm_rg.location
  username    = terraform.workspace
  ssh_pub_key = data.local_file.ssh_pub_key.content
  subnet_id   = data.azurerm_subnet.subnet_pub.id
  prefix      = var.prefix
  public_ip   = true

  tags = {
    env = terraform.workspace
    fnc = each.value.fnc
  }
}

module "lx_vm" {
  source   = "./modules/vm_linux"
  for_each = { for k, v in local.vms : k => v if v.os == "lx" }

  count_index = each.value.count_index
  size        = can(each.value.size) ? each.value.size : ""
  rg_name     = azurerm_resource_group.vm_rg.name
  region      = azurerm_resource_group.vm_rg.location
  username    = terraform.workspace
  ssh_pub_key = data.local_file.ssh_pub_key.content
  subnet_id   = data.azurerm_subnet.subnet_prv.id
  prefix      = var.prefix

  tags = {
    env = terraform.workspace
    fnc = each.value.fnc
  }
}

module "win_vm" {
  source   = "./modules/vm_windows"
  for_each = { for k, v in local.vms : k => v if v.os == "win" }

  count_index = each.value.count_index
  size        = can(each.value.size) ? each.value.size : ""
  rg_name     = azurerm_resource_group.vm_rg.name
  region      = azurerm_resource_group.vm_rg.location
  username    = terraform.workspace
  password    = var.win_pass
  subnet_id   = data.azurerm_subnet.subnet_prv.id
  prefix      = var.prefix

  tags = {
    env = terraform.workspace
    fnc = each.value.fnc
  }
}
