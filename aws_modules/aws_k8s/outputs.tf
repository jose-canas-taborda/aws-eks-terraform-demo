output "elastic_ip" {
    value = aws_eip.ip.public_ip
}

output "k8s-server-instance-sg" {
    value = aws_security_group.k8s-server-instance-sg.id
}