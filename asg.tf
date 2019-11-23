# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_region" "current" {
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We implement a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
    node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks_cluster.certificate_authority[0].data}' '${var.cluster_name}'
USERDATA
}

resource "aws_launch_configuration" "node" {
	associate_public_ip_address = true
	#iam_instance_profile        = aws_iam_instance_profile.node.name
	image_id                    = data.aws_ami.eks-worker.id
	instance_type               = "t2.micro"
	name_prefix                 = "terraform-eks-node"
	security_groups  = [aws_security_group.node-sg.id]
	user_data_base64 = base64encode(local.node-userdata)
	
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "node" {
	desired_capacity     = 2
	launch_configuration = aws_launch_configuration.node.id
	max_size             = 2
	min_size             = 1
	name                 = "terraform-eks-node"
	vpc_zone_identifier = module.vpc.public_subnet_ids[0]
	
	tag {
		key                 = "Name"
		value               = "terraform-eks-node"
		propagate_at_launch = true
	}
	
	tag {
		key                 = join("", ["kubernetes.io/cluster/", var.cluster_name])
		value               = "owned"
		propagate_at_launch = true
	}
}