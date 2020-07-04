module "create_vpc" {
    source = "./modules/networking"
    vpc_cidr = var.vpc_cidr
    public_subnet_names = ["Pub1", "Pub2", "Pub3"]
}

output "vpc_id_root_module" {
    value = module.create_vpc.vpc_id
}

variable "vpc_cidr" {
    default = "172.40.0.0/16"
}