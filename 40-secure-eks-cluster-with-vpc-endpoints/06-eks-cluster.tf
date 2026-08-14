resource "aws_eks_cluster" "example_eks_cluster" {
  name     = var.eks_cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true # set to false for more security
  }

  access_config {
    # three options for authentication_mode: CONFIG_MAP, API, API_AND_CONFIG_MAP
    authentication_mode                         = "API_AND_CONFIG_MAP" # 
    bootstrap_cluster_creator_admin_permissions = true
  }

  # enable EKS control plane logging for visibility and debugging
  enabled_cluster_log_types = [
    "api",               # API server audit logs
    "audit",             # Kubernetes audit logs
    "authenticator",     # Authenticator logs for IAM auth
    "controllerManager", # Logs for controller manager
    "scheduler"          # Logs for pod scheduling
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy,
    aws_vpc_endpoint.interface_endpoints
  ]
}