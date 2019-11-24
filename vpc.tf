data "aws_availability_zones" "available" {
}

locals {
    cluster_name = var.cluster_name
}

module "vpc" {
    source  = "./aws_modules/aws_vpc"
    cluster_name    = var.cluster_name
    cidr_block      = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    master_subnets_cidr = ["10.0.0.0/24","10.0.1.0/24"]
    worker_subnets_cidr = ["10.0.2.0/24","10.0.3.0/24"]
    public_subnets_cidr =  ["10.0.4.0/24","10.0.5.0/24"]
    private_subnets_cidr = ["10.0.6.0/24","10.0.7.0/24"]
}