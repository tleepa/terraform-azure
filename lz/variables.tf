variable "prefix" {
  type        = string
  description = "Prefix for resources' names"
}

variable "region" {
  type        = string
  description = "Azure location"
}

variable "address_space" {
  type        = string
  description = "Address space for Azure VNet"
}

variable "subnet_pub" {
  type        = string
  description = "Address range for public subnet"
}

variable "subnet_prv" {
  type        = string
  description = "Address range for public subnet"
}
