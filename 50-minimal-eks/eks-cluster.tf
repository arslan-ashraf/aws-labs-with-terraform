resource "aws_eks_cluster" "example_eks_cluster" {
  name     = "example_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.36"

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_a.id, 
      aws_subnet.public_subnet_b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}