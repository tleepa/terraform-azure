provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "terraform_remote_state" "lz" {
  backend = "local"

  config = {
    path = "../lz/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

resource "azurerm_resource_group" "vm_rg" {
  name     = "${var.prefix}-${terraform.workspace}-res"
  location = data.terraform_remote_state.lz.outputs.res_location
}

data "local_file" "ssh_pub_key" {
  filename = "${var.ssh_key_path}/${terraform.workspace}.pub"
}

module "lx_jb" {
  source   = "./modules/vm_linux"
  for_each = local.jbs

  count_index = each.value.count_index
  size        = can(each.value.size) ? each.value.size : ""
  rg_name     = azurerm_resource_group.vm_rg.name
  region      = azurerm_resource_group.vm_rg.location
  username    = terraform.workspace
  ssh_pub_key = data.local_file.ssh_pub_key.content
  subnet_id   = data.terraform_remote_state.lz.outputs.subnet_pub_id
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
  subnet_id   = data.terraform_remote_state.lz.outputs.subnet_prv_id
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
  subnet_id   = data.terraform_remote_state.lz.outputs.subnet_prv_id
  prefix      = var.prefix

  tags = {
    env = terraform.workspace
    fnc = each.value.fnc
  }
}
