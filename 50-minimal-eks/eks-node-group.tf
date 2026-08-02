resource "aws_eks_node_group" "eks_worker_nodes" {
  cluster_name    = aws_eks_cluster.example_eks_cluster.name
  node_group_name = "example-eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  
  subnet_ids      = [
    aws_subnet.public_subnet_a.id, 
    aws_subnet.public_subnet_b.id
  ]

  instance_types = [var.worker_node_instance_type]

  # ON_DEMAND or SPOT capacity types
  capacity_type = var.node_capacity_type

  # if ami is blank, AWS will pick the latest EKS optimized AMI
  # ami_type = "AL2023_x86_64_STANDARD"

  disk_size = var.node_disk_size

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  labels = {
    "Name" = "eks-worker-node"
  }

  tags = {
    Name = "eks-cluster-private-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only_policy,
  ]
}
