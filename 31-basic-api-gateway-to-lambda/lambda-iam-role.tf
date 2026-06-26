# define user/role based policy
data "aws_iam_policy_document" "lambda_policy_document" {
  # statement {
  #   effect = "Allow"

  #   principals {
  #     type        = "Service"
  #     identifiers = ["lambda.amazonaws.com"]
  #   }

  #   actions = ["sts:AssumeRole"]
  # }
}

resource "aws_iam_role" "lambda_role" {
  name               = "presigned_url_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
}


# IAM Policy to allow Lambda to issue PutObject/GetObject actions
data "aws_iam_policy_document" "lambda_s3_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.private_bucket.arn}/*"]
  }

}

resource "aws_iam_policy" "lambda_s3_policy" {
  name   = "lambda_s3_policy"
  policy = data.aws_iam_policy_document.lambda_s3_permissions.json
}


resource "aws_iam_role_policy_attachment" "lambda_s3_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}