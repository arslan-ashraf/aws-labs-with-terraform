output "lambda_url" {
  value = aws_lambda_function_url.example_lambda_url.function_url
}

output "cloudwatch_lambda_log_group_arn" {
  value = aws_cloudwatch_log_group.lambda_log_group.arn
}

output "cloudwatch_logs_region_userID" {
  value = "arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.user.account_id}"
}