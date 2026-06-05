# 4. Zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambada_function_code.py"
  output_path = "lambda_function.zip"
}

# 5. The URL Generation Lambda function
resource "aws_lambda_function" "url_generator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "generate-presigned-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambada_function_code.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.secure_bucket.id
    }
  }
}
