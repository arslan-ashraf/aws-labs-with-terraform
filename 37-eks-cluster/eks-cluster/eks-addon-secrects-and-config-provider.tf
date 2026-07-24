# note: the AWS ASCP (Amazon Secrets and Configuration Provider)
# automatically also installs the Kubernetes native pluggin (driver)
# Secrets Store CSI Driver

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "aws-secrets-store-csi-driver-provider"
}