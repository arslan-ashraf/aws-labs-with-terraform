# zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda_function_code.mjs"
  output_path = "lambda_function_code.zip"
}

# role that a user will temporarily have to be able to use the 
# presigned URL we import the arn of this role through the Lambda 
# function's environment variables
data "aws_iam_policy_document" "presigned_url_user_policy_document" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.private_bucket.arn}/*"]
  }
}

resource "aws_iam_role" "presigned_url_user_role" {
  name = "presigned_url_user_role"
  assume_role_policy = data.aws_iam_policy_document.presigned_url_user_policy_document.json
}

# Lambda function to generate the presigned URL
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
      PRESIGNED_URL_USE_PERMISSION_ROLE_ARN = aws_iam_role.presigned_url_user_role.arn
    }
  }

  # explicitly tell Lambda to use custom log group, without this block
  # Lambda will write to a log group whose name is
  # "/aws/lambda/<function_name>" or 
  # "/aws/lambda/${local.lambda_function_name}"
  # in this example: "/aws/lambda/generate-presigned-s3-url"
  logging_config {
    application_log_level = "INFO"
    system_log_level      = "DEBUG"
    log_format            = "JSON"
    log_group             = aws_cloudwatch_log_group.lambda_log_group.name
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group
  ]

}