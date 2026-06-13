# IAM Trust Policy JSON which allows EKS pods to assume a role
data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

# create IAM role
resource "aws_iam_role" "eks_pod_role" {
  name               = "eks-s3-reader-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json
}

## bring in S3 read only permissions JSON
data "aws_iam_policy_document" "s3_read_only_permissions" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = ["s3:ListAllMyBuckets"]
  }
}


# create policy that will take on persmissions defined
# in the JSON document imported by aws_iam_policy_document.s3_read_only_permissions
resource "aws_iam_policy" "s3_read_only_policy" {
  policy = data.aws_iam_policy_document.s3_read_only_permissions.json
  name   = "S3_read_only_policy"
}

# attach standard permissions (e.g., S3 Read Only)
resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.eks_pod_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

# create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "pod_association" {
  cluster_name    = var.cluster_name
  namespace       = "default"
  service_account = "s3-reader-service-account"
  role_arn        = aws_iam_role.eks_pod_role.arn

  depends_on = [
    module.eks
  ]
}