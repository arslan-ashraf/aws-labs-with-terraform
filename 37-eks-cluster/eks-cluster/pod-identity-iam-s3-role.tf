data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "pod_identity_S3_readonly_role" {
  name               = "eks-pod-identity-app-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json
}

# 3. Attach your functional application permissions (Example: S3 Read Only)
resource "aws_iam_role_policy_attachment" "app_permissions" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
