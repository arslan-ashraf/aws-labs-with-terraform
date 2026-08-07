resource "aws_iam_role" "pod_identity_secrets_manager_role" {
  name = "pod_identity_secrets_manager_role"

  # pod_identity_trust_policy has already been defined
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust_policy.json
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  account_id               = data.aws_caller_identity.current.account_id
  region                   = data.aws_region.current.region
  secrets_manager_base_arn = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret"
}

data "aws_iam_policy_document" "read_secrets_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    # resources = [var.database_secrets_arn]
    resources = ["${local.secrets_manager_base_arn}:my-secret*"]
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