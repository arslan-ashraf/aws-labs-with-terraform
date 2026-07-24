data "aws_iam_policy_document" "pod_identity_trust_policy" {
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
  name               = "pod_identity_S3_readonly_role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}


resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.pod_identity_S3_readonly_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}