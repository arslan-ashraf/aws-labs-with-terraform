resource "aws_eks_node_group" "private_nodes" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-cluster-private-node-group"
  node_role_arn = aws_iam_role.eks_node_group_role.arn

  # subnets where the worker nodes will be launched (private subnets)
  subnet_ids = data.terraform_remote_state.vpc_network.outputs.private_subnet_ids

  instance_types = var.node_instance_types

  # ON_DEMAND or SPOT capacity types
  capacity_type = var.node_capacity_type

  # ami for the worker nodes, the latest Amazon-managed OS 
  # optimized for EKS
  ami_type = "AL2023_x86_64_STANDARD"

  # Root volume size for each node (in GiB)
  disk_size = var.node_disk_size

  # configure auto-scaling limits and defaults
  scaling_config {
    # desired number of nodes when the node group is created
    desired_size = 2

    # minimum number of nodes allowed
    min_size = 1

    # maximum number of nodes the group can scale to
    max_size = 3
  }

  # set max percentage of nodes that can be unavailable during update
  update_config {
    max_unavailable_percentage = 33
  }

  # Force node group update when EKS AMI version changes
  force_update_version = true

  # Apply labels to each EC2 instance for easier scheduling and management in Kubernetes
  labels = {
    "env"  = "dev"
    "team" = "engineering"
  }

  # Tags for the node group and associated EC2 instances
  tags = {
    Name = "eks-cluster-private-node-group"
  }

  # Ensure IAM role policies are attached before creating the node group
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy
  ]
}