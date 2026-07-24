resource "aws_eks_pod_identity_association" "app_association" {
  cluster_name    = var.cluster_name
  namespace       = "production"
  service_account = "my-application-sa"
  role_arn        = aws_iam_role.app_role.arn
}