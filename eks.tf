resource "aws_eks_cluster" "eks_cluster" {
    name            = var.cluster_name
    role_arn        = aws_iam_role.cluster-role.arn
    
    vpc_config {
        security_group_ids = [aws_security_group.cluster-sg.id]
        subnet_ids         = module.vpc.public_subnet_ids[0]
    }
    
    depends_on = [
        aws_iam_role_policy_attachment.cluster-role-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.cluster-role-AmazonEKSServicePolicy,
    ]
}