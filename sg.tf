resource "aws_security_group" "cluster-sg" {
    name        = "terraform-eks-cluster-sg"
    description = "Cluster communication with worker nodes"
    vpc_id      = module.vpc.id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = join("", [var.cluster_name, "cluster-sg"])
    }
}

resource "aws_security_group" "node-sg" {
    name        = "terraform-eks-node-sg"
    description = "Security group for all nodes in the cluster"
    vpc_id      = module.vpc.id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = join("", [var.cluster_name, "node-sg"])
    }
}

resource "aws_security_group_rule" "cluster-sg-ingress-workstation-https" {
    cidr_blocks       = ["181.58.39.8/32"]
    description       = "Allow workstation to communicate with the cluster API Server"
    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.cluster-sg.id
    to_port           = 443
    type              = "ingress"
}

resource "aws_security_group_rule" "node-sg-ingress-self" {
    description              = "Allow node to communicate with each other"
    from_port                = 0
    protocol                 = "-1"
    security_group_id        = aws_security_group.node-sg.id
    source_security_group_id = aws_security_group.node-sg.id
    to_port                  = 65535
    type                     = "ingress"
}

resource "aws_security_group_rule" "node-sg-ingress-cluster" {
    description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
    from_port                = 1025
    protocol                 = "tcp"
    security_group_id        = aws_security_group.node-sg.id
    source_security_group_id = aws_security_group.cluster-sg.id
    to_port                  = 65535
    type                     = "ingress"
 }

 resource "aws_security_group_rule" "cluster-sg-ingress-node-https" {
    description              = "Allow pods to communicate with the cluster API Server"
    from_port                = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.cluster-sg.id
    source_security_group_id = aws_security_group.node-sg.id
    to_port                  = 443
    type                     = "ingress"
}