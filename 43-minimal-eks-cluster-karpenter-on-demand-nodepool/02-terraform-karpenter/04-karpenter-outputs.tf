# Helm installation outputs
output "helm_karpenter_metadata" {
  description = "Metadata Block outlining status of the deployed Helm release."
  value = helm_release.karpenter.metadata
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.example_eks_cluster.endpoint
  description = "EKS API Server endpoint"
}