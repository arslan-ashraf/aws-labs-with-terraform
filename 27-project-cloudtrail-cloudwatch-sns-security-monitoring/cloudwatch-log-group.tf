resource "aws_cloudwatch_log_group" "secrets_accessed_cloudwatch_log_group" {
  name              = "secrets_accessed_cloudwatch_log_group"
  retention_in_days = 14
}