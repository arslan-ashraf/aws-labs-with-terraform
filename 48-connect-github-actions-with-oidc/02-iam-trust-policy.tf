data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github_idp.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }


    condition {
      test     = "StringEquals" # use StringLike with * wild card
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:aws-labs-with-terraform/48-connect-github-actions-with-oidc:ref:refs/heads/main"
      ]
    }
  }
}