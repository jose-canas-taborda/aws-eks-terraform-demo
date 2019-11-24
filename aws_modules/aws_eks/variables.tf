variable "cluster-name" {}

variable "vpc_id" {
    description = "VPC ID "
}

variable "eks_subnets" {
    description = "Master subnet ids"
    type        = list
}

variable "worker_subnet" {
    type = list
}

variable "subnet_ids" {
    description = "List of all subnet in cluster"
}

variable "k8s-server-instance-sg" {
    description = "Kubenetes control server security group"
}