# Create the RBAC for ALB Ingress Controller
data "template_file" "rbac_role" {
	template = "${file("${path.module}/templates/rbac-role.yaml")}"
	vars = {
		cluster_name = "${var.cluster_name}"
	}
}

resource "local_file" "rbac_role_file" {
	content  = data.template_file.rbac_role.rendered
	filename = "config_output/rbac-role.yaml"
	
	provisioner "local-exec" {
		command = "kubectl apply -f config_output/rbac-role.yaml"
	}
}

# Deploy ALB Ingress Controller
data "template_file" "alb_ingress_deployment" {
	template = file("${path.module}/templates/alb-ingress-controller.yaml")
	
	vars = {
		cluster_name = "${var.cluster_name}"
	}
}

resource "local_file" "alb_ingress_deploymentfile" {
	depends_on = [local_file.rbac_role_file]
	content  = data.template_file.alb_ingress_deployment.rendered
	filename = "config_output/alb-ingress-controller.yaml"
	
	provisioner "local-exec" {
		command = "kubectl apply -f config_output/alb-ingress-controller.yaml"
	}
}