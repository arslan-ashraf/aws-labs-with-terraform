resource "aws_eks_access_entry" "karpenter_node_access" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.karpenter_node_role.arn
  type          = "EC2_LINUX"

  depends_on    = [
    aws_eks_cluster.example_eks_cluster,
    aws_eks_pod_identity_association.karpenter_PIA,
    aws_iam_role.karpenter_node_role
  ]
}