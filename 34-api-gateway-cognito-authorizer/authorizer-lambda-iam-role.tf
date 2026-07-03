data "aws_iam_policy_document" "authorizer_lambda_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "authorizer_lambda_role" {
  name               = "authorizer_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.authorizer_lambda_trust_policy_document.json
}