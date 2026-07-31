data "aws_eks_addon_version" "ebs_csi_driver_default_verison" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
}

# get latest EBS CSI Driver version compatible with EKS cluster's version
data "aws_eks_addon_version" "ebs_csi_driver_default_verison" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-ebs-csi-driver"

  resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  resolve_conflicts_on_update = "OVERWRITE" # concerning versions

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_node_group.private_nodes
  ]
}