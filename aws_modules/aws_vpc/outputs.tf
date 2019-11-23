output "id" {
    value = aws_vpc.this.id
}

output "public_subnet_ids" {
    value = [aws_subnet.public.*.id]
}

output "private_subnet_ids" {
    value = [aws_subnet.private.*.id]
}

output "cidr" {
    value = aws_vpc.this.cidr_block
}

output "public_route_table_id" {
    value = aws_default_route_table.public.id
}

output "private_route_table_id" {
    value = aws_route_table.private.id
}
/*
output "default_sg_id" {
    value = aws_default_security_group.this.id
}

output "nat_gateway_id" {
    value = module.nat_gateway.id
}

output "nat_gateway_ip" {
    value = module.nat_gateway.ip
}
*/