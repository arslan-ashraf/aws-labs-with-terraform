output "to_configure_kubectl" {
  description = "Command to update local kubeconfig to connect to the EKS cluster"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${var.eks_cluster_name}"
}

# EKS Cluster API server endpoint
# used by kubectl and external tools to communicate with the cluster
output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "EKS API Server endpoint"
}

# output the EKS Cluster Certificate Authority data
# its needed when setting up kubeconfig or accessing EKS via API
output "eks_cluster_certificate_authority_data" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "Base64 encoded CA certificate for kubectl config"
}