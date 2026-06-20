resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-${aws_instance.ec2_instance.id}"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = 50
  statistic           = "Maximum"

  # standard EC2 monitoring is published once every five minutes but with
  # detailed monitoring enabled on the EC2 instance, its published every minute

  # total evaluation time in seconds = period × evaluation_periods
  period             = 60 # time in seconds over which metric is aggregated
  evaluation_periods = 1  # number of these time windows CloudWatch looks at to decide the alarm state
  # so metric must breach threshold for 60 seconds * 1 periods = 60 seconds for alarm to go off

  alarm_description = "EC2 CPU utilization is very high.  Please take appropriate action."

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }

  alarm_actions = [
    aws_sns_topic.trigger_lambda_sns_topic.arn
  ]

}