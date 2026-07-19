resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = ["subnet-abcde123", "subnet-bcdef234"]
  }

  # CRITICAL: Always use depends_on for the policy attachment. 
  # If the attachment isn't fully created first, cluster provisioning will fail.
  # If deleted before the cluster during a destroy, EKS won't be able to clean up security groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}