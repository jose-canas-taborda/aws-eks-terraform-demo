data "aws_availability_zones" "available" {
}

# VPC
resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_support   = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    
    tags = {
        Name = join("-", [var.cluster_name, "vpc"])
        join("",["kubernetes.io/cluster/", var.cluster_name]) = "shared"
    }
}

## Subnets ##

# Public Subnet
resource "aws_subnet" "public_subnet" {
    count             = length(var.public_subnets_cidr)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.public_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = join("-", [var.cluster_name, "public", "subnets"])
        join("",["kubernetes.io/cluster/", var.cluster_name]) = "shared"
    }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
    count             = length(var.private_subnets_cidr)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.private_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = join("-", [var.cluster_name, "private", "subnets"])
    }
}

# EKS K8s Subnet
resource "aws_subnet" "master_subnet" {
    count             = length(var.master_subnets_cidr)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.master_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = join("-", [var.cluster_name, "master", "subnets"])
    }
}

# Worker Nodes
resource "aws_subnet" "worker_subnet" {
    count             = length(var.worker_subnets_cidr)
    vpc_id            = aws_vpc.this.id
    cidr_block        = var.worker_subnets_cidr[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = join("-", [var.cluster_name, "worker", "subnets"])
    }
}

# VPC Elastic IP
resource "aws_eip" "eip" {
	vpc = true
	
	tags = {
		Name = "Elastic IP"
	}
}

# Using default route table as Public route table
resource "aws_default_route_table" "rt_public" {
    default_route_table_id = aws_vpc.this.default_route_table_id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
    
    tags = {
        Name = join("-", [var.cluster_name, "public", "route-table"])
    }
}

# Master subnet rt association
resource "aws_route_table_association" "master" {
    count          = length(var.master_subnets_cidr)
    subnet_id      = element(aws_subnet.master_subnet.*.id, count.index)
    route_table_id = aws_default_route_table.rt_public.id
    depends_on     = [aws_subnet.master_subnet]
}

# Explicit  association between default route table and public subnets
resource "aws_route_table_association" "public" {
    count          = length(var.public_subnets_cidr)
    subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
    route_table_id = aws_default_route_table.public.id
    depends_on     = [aws_subnet.public_subnet]
}

# Internet gateway
resource "aws_internet_gateway" "this" {
	vpc_id = aws_vpc.this.id
	
	tags = {
		Name = join("-", [var.cluster_name, "internet", "gateway"])
	}
}

# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
	allocation_id = aws_eip.eip.id
	subnet_id     = element(aws_subnet.master_subnet.*.id, 0)
	
	tags {
		Name = "Nat_gateway"
	}
}

#Private Route Table
resource "aws_route_table" "rt_private" {
	vpc_id = aws_vpc.this.id
	
	route {
		cidr_block     = "0.0.0.0/0"
		nat_gateway_id = aws_nat_gateway.nat-gw.id
	}
	
	tags {
		Name = "Private_route_table"
	}
}

#Private Route Table Association
resource "aws_route_table_association" "worker" {
	count          = length(var.worker_subnets_cidr)
	subnet_id      = element(aws_subnet.worker_subnet.*.id, count.index)
	route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "private_sub" {
	count          = length(var.private_subnets_cidr)
	subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
	route_table_id = aws_route_table.rt_private.id
}