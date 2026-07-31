resource "aws_iam_role" "pod_identity_secrets_manager_role" {
  name = "pod_identity_secrets_manager_role"

  # pod_identity_trust_policy has already been defined
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}

data "aws_iam_policy_document" "read_secrets_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = [var.database_secrets_arn]
  }
}

resource "aws_iam_policy" "read_secrets_policy" {
  name   = "secrets-manager-read-policy"
  policy = data.aws_iam_policy_document.read_secrets_policy_document.json
}

resource "aws_iam_role_policy_attachment" "read_secrets_role_policy_attachment" {
  role       = aws_iam_role.pod_identity_secrets_manager_role.name
  policy_arn = aws_iam_policy.read_secrets_policy.arn
}