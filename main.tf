provider "aws" {
    region  = var.region
}

terraform {
    required_version = ">= 0.12.0"
    backend "s3" {
        encrypt = true
        bucket = "envio-demo-terraform-state"
        key    = "eks_aws/states"
        region = "us-east-1"
    }
}

# VPC - Production & Staging
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

module "k8s-server" {
    source        = "./aws_modules/aws_k8s"
    instance_type = "t2.micro"
    instance_ami  = "ami-02278c99dc08975a9"
    server-name   = var.server_name
    instance_key  = var.key_name
    vpc_id        = module.vpc.id
    k8-subnet     = module.vpc.public_subnet[0]
}

module "eks" {
    source                  = "./aws_modules/aws_eks"
    vpc_id                  = module.vpc.id
    cluster-name            = var.cluster_name
    k8s-server-instance-sg  = module.k8s-server.k8s-server-instance-sg
    eks_subnets             = module.vpc.master_subnet
    worker_subnet           = module.vpc.worker_node_subnet
    subnet_ids              = module.vpc.master_subnet#, module.vpc.worker_node_subnet])
}

# create an S3 bucket to store the state file in
resource "aws_s3_bucket" "envio-demo-terraform-state" {
    bucket = "envio-demo-terraform-state"
 
    versioning {
      enabled = true
    }
 
    lifecycle {
      prevent_destroy = false
    }
 
    tags = {
      Name = "S3 Remote Terraform State Store"
    }      
}