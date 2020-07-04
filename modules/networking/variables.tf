variable "vpc_cidr" {}
variable "create_vpc" {
  default = true
}

variable "vpc_name" {
  default = "Mgmt"
}

variable "environment" {
  default = "dev"
}

variable "public_subnet_names" {
  default = ["Pub1", "Pub2"]
}

variable "private_subnet_names" {
  default = ["Pri1", "Pri2"]
}
