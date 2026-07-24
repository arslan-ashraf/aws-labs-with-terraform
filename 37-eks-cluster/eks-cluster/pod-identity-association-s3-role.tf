resource "aws_eks_pod_identity_association" "app_association" {
  cluster_name    = var.eks_cluster_name
  namespace       = "production"
  service_account = "example-service-account"
  role_arn        = aws_iam_role.pod_identity_S3_read_only_role.arn
}