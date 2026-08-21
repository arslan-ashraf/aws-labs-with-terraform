data "aws_eks_addon_version" "ASCP_CSI_Driver_default_version" {
  addon_name         = "aws-secrets-store-csi-driver-provider"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
}


# get latest ASCP version compatible with EKS cluster's version
data "aws_eks_addon_version" "ASCP_CSI_Driver_latest" {
  addon_name         = "aws-secrets-store-csi-driver-provider"
  kubernetes_version = aws_eks_cluster.example_eks_cluster.version
  most_recent        = true
}


# note: the AWS ASCP (Amazon Secrets and Configuration Provider)
# automatically also installs the Kubernetes native pluggin (driver)
# Secrets Store CSI Driver, AWS ASCP pulls secrets from AWS Secrets
# Manager and hands them over to CSI Driver which then mounts those
# secrets into ephemeral in-memory temporary volumes through the 
# custom object SecretProviderClass
resource "aws_eks_addon" "ASCP_and_CSI_driver" {
  cluster_name  = var.eks_cluster_name
  addon_name    = "aws-secrets-store-csi-driver-provider"
  addon_version = data.aws_eks_addon_version.ASCP_CSI_Driver_latest.version

  resolve_conflicts_on_create = "OVERWRITE" # concerning versions
  resolve_conflicts_on_update = "OVERWRITE" # concerning versions

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_node_group.eks_worker_nodes
  ]

  # use this to configure the underlying heml chart that installs
  # Secrets Store CSI Driver:
  # configuration_values = jsonencode({
  #   secrets-store-csi-driver = {}
  #   replicaCount = 4
  #   resources = {
  #     limits = {
  #       cpu    = "100m"
  #       memory = "150Mi"
  #     }
  #     requests = {
  #       cpu    = "100m"
  #       memory = "150Mi"
  #     }
  #   }
  # })
}