resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14

  tags = {
    lambda_function_name = aws_lambda_function.presigned_url_generator_lambda.function_name
  }
}