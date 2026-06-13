# IAM Trust Policy JSON which allows EKS pods to assume a role
data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# create IAM role
resource "aws_iam_role" "eks_pod_role" {
  name               = "eks-s3-reader-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json
}

# attach standard permissions (e.g., S3 Read Only)
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.eks_pod_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "pod_association" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "s3-reader-sa"
  role_arn        = aws_iam_role.eks_pod_role.arn
}