# for learning only, we use the latest version
# get EKS addon version compatible with current EKS cluster version
data "aws_eks_addon_version" "metrics_server_default" {
  addon_name         = "metrics-server"
  kubernetes_version = var.kubernetes_version
}

# get latest EKS addon version compatible with current EKS cluster version
data "aws_eks_addon_version" "metrics_server_latest" {
  addon_name         = "metrics-server"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name                = var.eks_cluster_name
  addon_name                  = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  # use the latest compatible EKS addon version
  addon_version               = data.aws_eks_addon_version.metrics_server_latest.version
}