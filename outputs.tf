# CIDR blocks
output "kubeconfig" {
  value = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  value = module.eks.config_map_aws_auth
}

output "k8s-server-ip" {
  value = module.k8s-server.elastic_ip
}

output "cluster-name" {
  value = module.eks.cluster-name
}