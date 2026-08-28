# EKS Cluster API server endpoint
# used by kubectl and external tools to communicate with the cluster
output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.example_eks_cluster.endpoint
  description = "EKS API Server endpoint"
}

output "eks_cluster_id" {
  value       = aws_eks_cluster.example_eks_cluster.id
  description = "The id of the EKS cluster."
}

# to find supported EKS Addons based on EKS cluster version
output "eks_cluster_version" {
  value       = aws_eks_cluster.example_eks_cluster.version
  description = "EKS Kubernetes version"
}

# Helpful for scripting, `aws eks update-kubeconfig`, etc.
output "eks_cluster_name" {
  value       = aws_eks_cluster.example_eks_cluster.name
  description = "EKS cluster name"
}

# output the EKS Cluster Certificate Authority data
# its needed when setting up kubeconfig or accessing EKS via API
output "eks_cluster_certificate_authority_data" {
  value       = aws_eks_cluster.example_eks_cluster.certificate_authority[0].data
  sensitive   = true # only hides from output logs but still present in state file
  description = "Base64 encoded CA certificate for kubectl config"
}

output "command_to_configure_kubectl" {
  description = "Command to update local kubeconfig to connect to the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.eks_cluster_name}"
}