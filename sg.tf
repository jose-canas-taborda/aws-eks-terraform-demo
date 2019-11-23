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
        Name = "terraform-eks-demo"
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