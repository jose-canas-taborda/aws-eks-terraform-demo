variable "cluster_name" {}

variable "cidr_block" {}

variable "enable_dns_support" {
    default = true
}

variable "enable_dns_hostnames" {
    default = false
}

variable "public_subnets_cidr" {
    default = []
}

variable "private_subnets_cidr" {
    default = []
}

variable "master_subnets_cidr" {
    default = []
}

variable "worker_subnets_cidr" {
    default = []
}

variable "nat_gateway" {
    default = false
}
