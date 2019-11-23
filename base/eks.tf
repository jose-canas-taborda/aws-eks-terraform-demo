/*module "eks" {
    source       = "../.."
    cluster_name = local.cluster_name
    subnets      = module.vpc.private_subnets
    
    tags = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
    }

    vpc_id = module.vpc.vpc_id

    worker_groups = [
        {
            name                          = "worker-group-1"
            instance_type                 = "t2.small"
            additional_userdata           = "echo foo bar"
            asg_desired_capacity          = 2
            additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
        },
        {
            name                          = "worker-group-2"
            instance_type                 = "t2.medium"
            additional_userdata           = "echo foo bar"
            additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
            asg_desired_capacity          = 1
        },
    ]

    worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    map_roles                            = var.map_roles
    map_users                            = var.map_users
    map_accounts                         = var.map_accounts
}
*/