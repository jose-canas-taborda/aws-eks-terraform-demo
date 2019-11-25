variable "profile" {
  description = "AWS User account Profile"
  default = "mariajosefa"
}

variable "region" {
    default = "us-east-1"
}

variable "cluster-name" {
    default = "eks-aws-cluster"
    type    = string
}

variable "key_name" {
    type    = string
    default   = "terraform-eks-key"
}

variable "server_name" {
    type    = string
    default   = "k8s-server"
}

variable "sub_ids" {
  default = []
}

variable "instance-ami" {
  default = "ami-07d6c8e62ce328a10" # AMI of amazon-eks-node-1.14-v20191119 November 19, 2019
}

variable "instance_type" {
  default = "t2.micro"
}

variable "server-name" {
  description = "Ec2 Server Name"
  default     = "eks-server-demo"
}

variable "vpc_name" {
  description = "VPC name"
  default     = "eks-vpc-demo"
}