resource "aws_eks_node_group" "eks_worker_nodes" {
  cluster_name    = aws_eks_cluster.example_eks_cluster.name
  node_group_name = "example-eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # ami_type       = "AL2_x86_64" # Default Amazon Linux 2 EKS AMI

  # Reference the Custom Launch Template
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only_policy,
    aws_vpc_endpoint.interface_endpoints
  ]
}