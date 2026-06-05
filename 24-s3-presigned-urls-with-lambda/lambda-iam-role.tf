# define user/role based policy
data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "presigned_url_lambda_role"

  assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
}

# IAM Policy to allow Lambda to issue PutObject/GetObject actions
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "lambda_s3_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["s3:PutObject", "s3:GetObject"]
      Effect   = "Allow"
      Resource = "${aws_s3_bucket.secure_bucket.arn}/*"
    }]
  })
}