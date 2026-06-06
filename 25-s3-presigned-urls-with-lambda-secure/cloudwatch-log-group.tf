resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "lambda_log_group"
  retention_in_days = 14
}