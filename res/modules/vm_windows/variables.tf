variable "rg_name" {}

variable "region" {}

variable "size" {}

variable "default_size" {
  default = "Standard_B1s"
}

variable "prefix" {}

variable "count_index" {}

variable "subnet_id" {}

variable "username" {}

variable "password" {
  sensitive = true
}

variable "public_ip" {
  type    = bool
  default = false
}

variable "public_ip_id" {
  default = ""
}

variable "image" {
  type = map(any)
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

variable "tags" {
  type = map(any)
  default = {
    fnc = "gen"
  }
}
