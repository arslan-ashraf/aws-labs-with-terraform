resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "lambda_log_group"
  retention_in_days = 14

  tags = {
    lambda_function_name = aws_lambda_function.presigned_url_generator_lambda.function_name
  }
}