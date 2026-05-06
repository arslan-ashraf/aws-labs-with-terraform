data "aws_caller_identity" "user" {}
data "aws_region" "current_region" {}


# there are two parts to IAM: WHO and WHAT, who can do what
# here is the WHO part, we bring the JSON document from AWS that says 
# the who part (or principal) is the lambda service and it is "allowed"
# to take the action of assuming a role, "sts:AssumeRole"
data "aws_iam_policy_document" "assume_lambda_execution_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# here we create the IAM role with the JSON document imported above
resource "aws_iam_role" "lambda_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_execution_role.json
  name = "manually-created-lambda-role-7fe1453s"
  path = "/service-role/"
}


# because the IAM role already exists, we use the import {} block to import
# it into Terraform
import {
  to = aws_iam_role.lambda_execution_role
  id = "manually-created-lambda-role-7fe1453s"
}


# here is the WHAT part, we bring the JSON document from AWS that says 
# this document holds two sets of permissions, hence two statements
# one is to create the log group, and the other is to create a log stream
# inside the log group as well as writing log events
data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"
    resources = ["arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.user.account_id}:*"]
    action = ["logs:CreateLogGroup"]
  }

  statement {
    effect = "Allow"
    resources = ["${aws_cloudwatch_log_group.lambda_log_group.arn}:*"]
    action = ["logs:CreateLogStream", "logs:PutLogEvents"]
  }
}

# here we create the policy that will take on persmissions defined
# in the JSON document imported by aws_iam_policy_document.lambda_permissions
resource "aws_iam_policy" "lambda_policy" {
  policy = data.aws_iam_policy_document.lambda_permissions.json
  name = ""
  path = "/service-role/"
}


# because the IAM role already exists, we use the import {} block to import
# it into Terraform
import {
  to = aws_iam_policy.lambda_policy
  id = "arn:aws:iam::${data.aws_caller_identity.user.account_id}:policy/service-role/AWSLambdaBasicExecutionRole-eb89ac7f-22a0-4f9d-b7a7-2decd747f19e"
}


# here we attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  role = aws_iam_role.lambda_execution_role
  policy_arn = aws_iam_policy.lambda_policy.arn
}