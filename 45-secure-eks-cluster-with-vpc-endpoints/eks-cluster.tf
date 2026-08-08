resource "aws_eks_cluster" "main" {
  name     = "${var.name}-cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.30"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  
  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = module.vpc.private_subnets[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets_kms_key.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks_cluster
  ]
}