data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda_function_code.mjs"
  output_path = "lambda_function_code.zip"
}

locals  {
  lambda_function_name = "cloudwatch-alarm-response-lambda-handler"
}

resource "aws_lambda_function" "target_lambda" {
  filename      = "lambda_function_code.zip"
  function_name = "cloudwatch-alarm-response-lambda-handler"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function_code.handler"
  runtime       = "nodejs24.x"

  memory_size   = 128       # in megabytes
  timeout       = 5         # in seconds
}


# Lambda resource based policy to allow SNS to invoke the Lambda function
resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "Allow Lambda execution from SNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.trigger_lambda_sns_topic.arn
}