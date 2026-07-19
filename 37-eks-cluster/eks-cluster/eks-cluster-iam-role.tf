data "aws_iam_policy_document" "eks_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"
  assume_role_policy = data.aws_iam_policy_document.eks_trust_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name

  # this policy is what allows EKS cluster control plane to be able to
  # spin up basic components like ENIs, load balancers, security groups, etc
  # this is mandatory for all EKS clusters
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ------------------------------------------------------------------------------
# Attach VPC Resource Controller policy
# Required for advanced networking, Fargate, and Karpenter support
# Recommended to include by default for production-grade EKS
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name

  # this policy is required for advanced networking, Fargate, and
  # Karpenter
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}