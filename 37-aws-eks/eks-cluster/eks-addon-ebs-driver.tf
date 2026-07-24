resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-ebs-csi-driver"

  # resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  # resolve_conflicts_on_update = "OVERWRITE" # concerning versions
}