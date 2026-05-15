resource "aws_cloudwatch_log_group" "vpc_logs_group" {
  name = "vpc_logs_group"
  retention_in_days = 30
}

resource "aws_flow_log" "example_vpc_flow_logs" {
  traffic_type = "ALL"
  eni_id = "Optional"
  iam_role_arn = 
  log_destination = "Optional"
  log_group_name = "Optional"
  subnet_id = "Optional"
  vpc_id = "Optional"
}