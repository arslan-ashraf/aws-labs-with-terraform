# 4. Zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambada_function_code.js"
  output_path = "lambda_function.zip"
}

# 5. The URL Generation Lambda function
resource "aws_lambda_function" "presigned_url_generator_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "generate-presigned-url"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambada_function_code.handler"
  runtime          = "nodejs24.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = 128
  timeout     = 5

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.private_bucket.id
    }
  }

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  
}