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

variable "ssh_pub_key" {}

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
    publisher = "almalinux"
    offer     = "almalinux"
    sku       = "8_5-gen2"
    version   = "latest"
  }
}

variable "tags" {
  type = map(any)
  default = {
    fnc = "gen"
  }
}
