# 4. Zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda_function_code.mjs"
  output_path = "lambda_function_code.zip"
}

# 5. The URL Generation Lambda function
resource "aws_lambda_function" "presigned_url_generator_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "generate-presigned-s3-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function_code.handler"
  runtime          = "nodejs24.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = 128       # in megabytes
  timeout     = 5         # in seconds

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.private_bucket.id
      BUCKET_ARN  = aws_s3_bucket.private_bucket.arn
    }
  }

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

}