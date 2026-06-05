# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Create a fully private S3 bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket        = "my-secure-app-bucket-unique-id"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "private_block" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. IAM Role for Lambda
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

# 4. Zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function.zip"
}

# 5. The URL Generation Lambda function
resource "aws_lambda_function" "url_generator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "generate-presigned-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.secure_bucket.id
    }
  }
}
