resource "aws_cloudwatch_log_group" "vpc_logs_group" {
  name = "vpc_logs_group"
  retention_in_days = 30
}

resource "aws_flow_log" "example_vpc_flow_logs" {
  traffic_type = "ALL"
  iam_role_arn = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_logs_group.arn
  vpc_id = aws_vpc.example_vpc.id
  max_aggregation_interval = 60
}