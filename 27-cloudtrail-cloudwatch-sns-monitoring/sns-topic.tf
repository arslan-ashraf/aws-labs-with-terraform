resource "aws_sns_topic" "ec2_cpu_alerts" {
  name = "ec2_cpu_alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ec2_cpu_alerts.arn
  protocol  = "email"
  endpoint  = var.email_for_alerts
}