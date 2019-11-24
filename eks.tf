resource "aws_eks_cluster" "eks_cluster" {
    name            = var.cluster_name
    role_arn        = aws_iam_role.eks_kubectl_role.arn
    
    vpc_config {
        security_group_ids = [aws_security_group.cluster-sg.id]
        subnet_ids         = [module.vpc.master_subnet, module.vpc.worker_node_subnet]
    }
    
    depends_on = [
        aws_iam_role_policy_attachment.eks_kubectl-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.eks_kubectl-AmazonEKSServicePolicy,
        aws_iam_role_policy_attachment.eks_kubectl-AmazonEKSWorkerNodePolicy,
    ]
}

data "aws_ami" "eks-worker-ami" {
    filter {
        name   = "name"
        values = [join("", ["amazon-eks-node-", aws_eks_cluster.eks_cluster.version,"-v*"])]
    }
    
    most_recent = true
    owners      = ["602401143452"] # Amazon EKS AMI Account ID
}