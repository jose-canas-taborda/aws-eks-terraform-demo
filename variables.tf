variable "profile" {
  description = "AWS User account Profile"
  default = "mariajosefa"
}

variable "region" {
    default = "us-east-1"
}

variable "cluster_name" {
    default = "eks-aws-cluster"
    type    = string
}

variable "key_name" {
    type    = string
    default   = "id_rsa"
}

variable "server_name" {
    type    = string
    default   = "k8s-server"
}

variable "sub_ids" {
  default = []
}

variable "instance-ami" {
  default = "ami-02278c99dc08975a9" # AMI of Mumbai region
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