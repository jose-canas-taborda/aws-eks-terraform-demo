data "aws_availability_zones" "available" {
}

resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    
    tags = {
        Name = join("-", [var.cluster_name, "vpc"])
        join("",["kubernetes.io/cluster/", var.cluster_name]) = "shared"
    }
}

resource "aws_default_security_group" "this" {
    vpc_id = aws_vpc.this.id
    
    ingress {
        protocol  = -1
        self      = true
        from_port = 0
        to_port   = 0
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = join("-", [var.cluster_name, "default", "sg"])
        join("",["kubernetes.io/cluster/", var.cluster_name]) = "shared"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
      Name = join("-", [var.cluster_name, "internet", "gateway"])
  }
}

resource "aws_subnet" "public" {
    count             = length(var.public_subnets)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.public_subnets[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = join("-", [var.cluster_name, "public", "subnets"])
        join("",["kubernetes.io/cluster/", var.cluster_name]) = "shared"
    }
}

resource "aws_subnet" "private" {
    count             = length(var.private_subnets)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.private_subnets[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = join("-", [var.cluster_name, "private", "subnets"])
    }
}

# Using default route table as Public route table
resource "aws_default_route_table" "public" {
    default_route_table_id = aws_vpc.this.default_route_table_id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
    
    tags = {
        Name = join("-", [var.cluster_name, "public", "route-table"])
    }
}

# Explicit  association between default route table and public subnets
resource "aws_route_table_association" "public" {
    count          = length(var.public_subnets)
    subnet_id      = element(aws_subnet.public.*.id, count.index)
    route_table_id = aws_default_route_table.public.id
    depends_on     = [aws_subnet.public]
}

# Private route table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.this.id
    
    tags = {
        Name = join("-", [var.cluster_name, "private", "route-table"])
    }
}

# Only associate private networks
resource "aws_route_table_association" "private" {
    count          = length(var.private_subnets)
    subnet_id      = element(aws_subnet.private.*.id, count.index)
    route_table_id = aws_route_table.private.id
    depends_on     = [aws_subnet.private]
}