resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "secret_in_SecretsManager_accessed"
  namespace           = "AWS/CloudTrail"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "SecretAccessed"
  threshold           = var.number_of_secret_accesses
  statistic           = "SUM"

  # total evaluation time in seconds = period × evaluation_periods
  period             = 60 # time in seconds over which metric is aggregated
  evaluation_periods = 1  # number of these time windows CloudWatch looks at to decide the alarm state
  # so metric must breach threshold for 60 seconds * 1 periods = 60 seconds for alarm to go off

  alarm_description = "Secret in SecretsManager has been accessed!"

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }

  alarm_actions = [
    aws_sns_topic.secret_accessed_alerts.arn
  ]
}