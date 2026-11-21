resource "aws_iam_role" "github_actions_role" {
  name        = "github_actions_role"
  description = "IAM role assumed by GitHub Actions through OIDC"

  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json

  max_session_duration = 3600
}

data "aws_iam_policy_document" "github_actions_role_permissions" {

  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets"
    ]

    resources = ["*"]
  }

}

resource "aws_iam_policy" "github_actions_policy" {
  name   = "github_actions_policy"
  policy = data.aws_iam_policy_document.github_actions_role_permissions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}