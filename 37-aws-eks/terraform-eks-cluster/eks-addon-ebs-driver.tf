resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-ebs-csi-driver"

  # resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  # resolve_conflicts_on_update = "OVERWRITE" # concerning versions

  # Eensure the Pod Identity Association is created first
  depends_on = [
    aws_eks_addon.podidentity,
    aws_eks_pod_identity_association.service_account_ebs_iam_assoc
    aws_eks_node_group.private_nodes
  ]

}