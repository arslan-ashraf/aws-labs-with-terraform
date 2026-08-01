resource "aws_cloudwatch_metric_alarm" "api_secret_accessed_alarm" {
  alarm_name          = "secret_in_SecretsManager_accessed"
  namespace           = "SecurityMetrics"      # must match metric filter namespace
  metric_name         = "secret_access_count"  # must match metric filter name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.number_of_secret_accesses
  statistic           = "Sum"

  # total evaluation time in seconds = period × evaluation_periods
  period             = 60 # time in seconds over which metric is aggregated
  evaluation_periods = 1  # number of these time windows CloudWatch looks at to decide the alarm state
  # so metric must breach threshold for 60 seconds * 1 periods = 60 seconds for alarm to go off

  alarm_description = "Secret in SecretsManager has been accessed!"

  alarm_actions = [
    aws_sns_topic.secret_accessed_alerts.arn
  ]
}