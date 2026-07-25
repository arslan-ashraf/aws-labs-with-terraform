resource "aws_eks_pod_identity_association" "service_account_ebs_iam_assoc" {
  cluster_name    = var.eks_cluster_name
  namespace       = "production"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.pod_identity_ebs_volumes_role.arn

  # wait for the pod identity agent addon to be created first
  depends_on      = [aws_eks_addon.pod_identity_agent]
}