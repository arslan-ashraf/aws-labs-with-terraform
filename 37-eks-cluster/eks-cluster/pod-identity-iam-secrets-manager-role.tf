resource "aws_iam_role" "pod_identity_secrets_manager_role" {
  name               = "pod_identity_secrets_manager_role"

  # pod_identity_trust_policy has already been defined
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}

data "aws_iam_policy_document" "read_secrets_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    # replace "*" with secrets' arn
    resources = ["*"]
  }
}


resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.pod_identity_secrets_manager_role.name
  policy_arn = data.aws_iam_policy_document.read_secrets_policy.arn
}