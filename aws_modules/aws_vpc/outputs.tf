output "id" {
    value = aws_vpc.this.id
}

output "vpc_cidr_block" {
    value = aws_vpc.this.cidr_block
}

output "master_subnet" {
    value = [aws_subnet.master_subnet.*.id]
}

output "public_subnet" {
    value = aws_subnet.public_subnet.*.id
}

output "private_subnet" {
    value = [aws_subnet.private_subnet.*.id]
}

output "worker_node_subnet" {
    value = [aws_subnet.worker_subnet.*.id]
}