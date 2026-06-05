

resource "aws_iam_role" "lambda_role" {
  name = "presigned_url_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "://amazonaws.com" }
    }]
  })
}

# 3. IAM Policy to allow Lambda to issue PutObject/GetObject actions
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