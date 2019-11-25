provider "aws" {
    region  = var.region
}

terraform {
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
    cluster_name    = var.cluster-name
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
    instance_ami  = "ami-07d6c8e62ce328a10"
    server-name   = var.server_name
    instance_key  = var.key_name
    vpc_id        = module.vpc.id
    k8-subnet     = module.vpc.public_subnet[0]
}

module "eks" {
    source                  = "./aws_modules/aws_eks"
    vpc_id                  = module.vpc.id
    cluster-name            = var.cluster-name
    k8s-server-instance-sg  = module.k8s-server.k8s-server-instance-sg
    eks_subnets             = module.vpc.master_subnet
    worker_subnet           = module.vpc.worker_node_subnet
    public_subnet_ids       = module.vpc.public_subnet #, module.vpc.worker_node_subnet])
    private_subnet_ids      = module.vpc.private_subnet
}

module "k8s_ingress_controller" {
	source = "./aws_modules/alb_nginx_ingress"
	
	cluster_endpoint = module.eks.endpoint
	cluster_name     = module.eks.cluster-name
}

# Key pair
resource "aws_key_pair" "terraform-eks-key" {
  key_name = "terraform-eks-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBm3/f2rQUfwS2c5+z+V8+FD1syJYr7Gcge6NaYAqH4SVkli3E7N9awwwYwguQij7kmW/qopDHgfHS7k20Q9UvuMft+iJ69Nsrodg2Yi+z/SjbOrTcycuJ87L2JVpM/bbyUObn6if3GXSy8pElM/shyylzMSq9VryN38PLaz5yFQmBRSVWfiCxlda7b0yACb/cGaP0zE1vCufFiFOHohFEZkch6BUprPdENvcVB1Yft0Z9NsLaaRzDEFKAIEAoXsZGXQSLSeChcko+qKhSsL6o48zeV1clApJ/KZRp0cLA4fIJtZp51FKHtomU2x7MoeK//BfUlalCAjrdp1iZ5eTaF rsa-key-20191124"
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