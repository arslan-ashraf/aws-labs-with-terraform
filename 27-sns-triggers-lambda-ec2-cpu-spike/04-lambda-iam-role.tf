data "aws_iam_policy_document" "lambda_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_alarm_handler_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy_document.json
}