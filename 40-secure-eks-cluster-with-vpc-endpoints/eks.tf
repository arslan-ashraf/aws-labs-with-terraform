# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "isolated-eks-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    endpoint_private_access = true
    endpoint_public_access  = true # Set to false for absolute air-gapped security
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_vpc_endpoint.interfaces
  ]
}

# Managed Node Group
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "isolated-nodes"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  # ami_type       = "AL2_x86_64" # Default Amazon Linux 2 EKS AMI

  # Reference the Custom Launch Template
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_vpc_endpoint.interfaces
  ]
}