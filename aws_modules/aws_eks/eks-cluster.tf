# IAM Role for the EKS cluster
resource "aws_iam_role" "cluster-role" {
    name = "cluster-iam-role"
    assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}

# Assign of policies to the iam role
resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = aws_iam_role.cluster-role.name
}

# Security Groups
resource "aws_security_group" "cluster-sg" {
    name        = "terraform-eks-cluster-sg"
    description = "Cluster communication with worker nodes"
    vpc_id      = var.vpc_id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = join("", [var.cluster-name, "cluster-sg"])
    }
}

# SG Rules
resource "aws_security_group_rule" "cluster-ingress-node-https" {
    description              = "Allow pods to communicate with the cluster API Server"
    from_port                = 443
    protocol                 = "tcp"
    security_group_id        = aws_security_group.cluster-sg.id
    source_security_group_id = aws_security_group.worker-node-sg.id
    to_port                  = 443
    type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
    cidr_blocks       = ["0.0.0.0/0"]#["181.58.39.8/32"]
    description       = "Allow workstation to communicate with the cluster API Server"
    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.cluster-sg.id
    to_port           = 443
    type              = "ingress"
}

# EKS Service
resource "aws_eks_cluster" "eks-cluster" {
    name     = var.cluster-name
    role_arn = aws_iam_role.cluster-role.arn
    
    vpc_config {
        security_group_ids = [aws_security_group.cluster-sg.id]
        subnet_ids         = var.public_subnet_ids
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
    ]
}

# EKS Node Group Development
resource "aws_eks_node_group" "node-group-dev" {
    cluster_name    = aws_eks_cluster.eks-cluster.name
    node_group_name = "node-group-dev"
    node_role_arn   = aws_iam_role.worker-node-role.arn
    subnet_ids      = var.private_subnet_ids[0]
    instance_types  = ["t2.micro"]
    
    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }
}

# EKS Node Group Staging
resource "aws_eks_node_group" "node-group-stg" {
    cluster_name    = aws_eks_cluster.eks-cluster.name
    node_group_name = "node-group-stg"
    node_role_arn   = aws_iam_role.worker-node-role.arn
    subnet_ids      = var.private_subnet_ids[0]
    instance_types  = ["t2.micro"]
    
    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }
}

# EKS Node Group Production
resource "aws_eks_node_group" "node-group-prd" {
    cluster_name    = aws_eks_cluster.eks-cluster.name
    node_group_name = "node-group-prd"
    node_role_arn   = aws_iam_role.worker-node-role.arn
    subnet_ids      = var.public_subnet_ids
    instance_types  = ["t2.micro"]
    
    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }
}