resource "aws_eks_pod_identity_association" "karpenter_PIA" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "karpenter-sa"
  role_arn        = aws_iam_role.karpenter_controller_role.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}