resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-${aws_instance.ec2_instance.id}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_interval = 60 # frequency in seconds at which alarm is evaluated
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 10 # number of periods over which alarm is evaluated, 60 * 10 = 600
  statistic           = "Maximum"
  threshold           = var.cpu_alarm_threshold

  alarm_description = "EC2 CPU utilization is very high.  Please take appropriate action."

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }

  alarm_actions = [
    aws_sns_topic.ec2_cpu_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.ec2_cpu_alerts.arn
  ]
}