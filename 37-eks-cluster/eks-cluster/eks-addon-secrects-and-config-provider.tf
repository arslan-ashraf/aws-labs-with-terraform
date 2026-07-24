resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = var.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"
}

aws-secrets-store-csi-driver-provider