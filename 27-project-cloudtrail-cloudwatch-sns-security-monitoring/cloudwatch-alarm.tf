resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "secret_in_SecretsManager_accessed"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = var.number_of_secret_accesses
  statistic           = "Maximum"

  # total evaluation time in seconds = period × evaluation_periods
  period             = 60 # time in seconds over which metric is aggregated
  evaluation_periods = 1  # number of these time windows CloudWatch looks at to decide the alarm state
  # so metric must breach threshold for 60 seconds * 1 periods = 60 seconds for alarm to go off

  alarm_description = "EC2 CPU utilization is very high.  Please take appropriate action."

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }

  alarm_actions = [
    aws_sns_topic.ec2_cpu_alerts.arn
  ]

  # list of actions to execute when this alarm transitions into an OK state
  ok_actions = [
    aws_sns_topic.ec2_cpu_alerts.arn
  ]
}