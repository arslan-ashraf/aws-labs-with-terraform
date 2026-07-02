# define user/role based policy
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

resource "aws_iam_role" "backend_lambda_role" {
  name               = "backend_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy_document.json
}


# IAM Policy to allow Lambda to issue PutObject/GetObject actions
# data "aws_iam_policy_document" "lambda_dynamoDB_CRUD_permissions" {

#   statement {
#     effect    = "Allow"

#     actions   = [
#       "dynamodb:GetItem",
#       "dynamodb:DeleteItem",
#       "dynamodb:PutItem",
#       "dynamodb:Scan",
#       "dynamodb:Query",
#       "dynamodb:UpdateItem",
#       "dynamodb:BatchWriteItem",
#       "dynamodb:BatchGetItem",
#       "dynamodb:DescribeTable",
#     ]

#     resources = [
#       "${aws_dynamodb_table.users_table.arn}",
#       "${aws_dynamodb_table.users_table.arn}/*"
#     ]
#   }

#   statement {
#     effect = "Allow"
#     actions = ["dynamodb:ListTables"]
#     resources = ["*"]
#   }

# }

# resource "aws_iam_policy" "lambda_dynamoDB_CRUD_policy" {
#   name   = "lambda_dynamoDB_CRUD_policy"
#   policy = data.aws_iam_policy_document.lambda_dynamoDB_CRUD_permissions.json
# }


# resource "aws_iam_role_policy_attachment" "lambda_s3_role_policy_attachment" {
#   role       = aws_iam_role.lambda_dynamoDB_role.name
#   policy_arn = aws_iam_policy.lambda_dynamoDB_CRUD_policy.arn
# }