variable "cluster_name" {}

variable "cidr_block" {}

variable "enable_dns_support" {
    default = true
}

variable "enable_dns_hostnames" {
    default = false
}

variable "public_subnets" {
    default = []
}

variable "private_subnets" {
    default = []
}

variable "nat_gateway" {
    default = false
}
