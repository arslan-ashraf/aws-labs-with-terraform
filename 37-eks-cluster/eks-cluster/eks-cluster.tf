resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  # VPC configuration for control plane networking
  vpc_config {
    # subnets where EKS control plane ENIs will be placed (should be private)
    subnet_ids = data.terraform_remote_state.vpc_network.outputs.private_subnet_ids

    # allow access to private endpoint (inside VPC)
    endpoint_private_access = var.cluster_endpoint_private_access

    # allow access to public endpoint (from internet, controlled via CIDRs)
    endpoint_public_access  = var.cluster_endpoint_public_access

    # list of CIDRs allowed to reach the public endpoint
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  # enable EKS control plane logging for visibility and debugging
  enabled_cluster_log_types = [
    "api",                 # API server audit logs
    "audit",               # Kubernetes audit logs
    "authenticator",       # Authenticator logs for IAM auth
    "controllerManager",   # Logs for controller manager
    "scheduler"            # Logs for pod scheduling
  ]

  # CRITICAL: Always use depends_on for the policy attachment. 
  # If the attachment isn't fully created first, cluster provisioning will fail.
  # If deleted before the cluster during a destroy, EKS won't be able to clean up security groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}