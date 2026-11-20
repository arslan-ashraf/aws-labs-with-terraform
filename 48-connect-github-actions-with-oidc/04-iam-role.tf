resource "aws_iam_role" "github_actions_iam_role" {
  description = "IAM role assumed by GitHub Actions through OIDC"

  assume_role_policy = data.aws_iam_policy_document.github_trust_policy.json

  max_session_duration = 3600
}