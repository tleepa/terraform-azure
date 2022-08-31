variable "prefix" {
  type = string
}

variable "win_pass" {
  type      = string
  sensitive = true
}

variable "ssh_key_path" {
  type = string
}
