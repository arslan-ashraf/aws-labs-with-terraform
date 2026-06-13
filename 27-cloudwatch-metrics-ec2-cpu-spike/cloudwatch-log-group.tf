resource "aws_cloudwatch_log_group" "ec2_metrics_log_group" {
  name = "ec2_metrics_log_group"
  retention_in_days = 30
}