resource "aws_eks_cluster" "example_eks_cluster" {
  name     = var.eks_cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id, 
      aws_subnet.private_subnet_2.id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true # set to false for more security
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_vpc_endpoint.interface_endpoints
  ]
}