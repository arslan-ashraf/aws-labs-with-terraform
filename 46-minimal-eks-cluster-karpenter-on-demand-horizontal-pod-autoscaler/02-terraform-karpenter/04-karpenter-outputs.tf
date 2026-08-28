# Helm installation outputs
output "helm_karpenter_metadata" {
  value       = helm_release.karpenter.metadata
  description = "Metadata Block outlining status of the deployed Helm release."
}

output "karpenter_node_role_arn" {
  value       = aws_iam_role.karpenter_node_role.arn
  description = "karpenter node role ARN"
}