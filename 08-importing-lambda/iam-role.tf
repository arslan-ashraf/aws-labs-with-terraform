data "aws_caller_identity" "user" {}
data "aws_region" "current_region" {}

data "aws_iam_policy_document" "policy_lambda_execution" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


import {
  to = aws_iam_role.lambda_execution_role
  id = "manually-created-lambda-role-7fe1453s"
}

import {
  to = aws_iam_policy.lambda_execution_policy
  id = "arn:aws:iam::${data.aws_caller_identity.user.account_id}:policy/service-role/AWSLambdaBasicExecutionRole-eb89ac7f-22a0-4f9d-b7a7-2decd747f19e"
}