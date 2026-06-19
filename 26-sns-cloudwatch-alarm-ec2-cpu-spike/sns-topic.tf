resource "aws_sns_topic" "ec2_cpu_alerts_sns_topic" {
  name = "ec2_cpu_alerts_sns_topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.ec2_cpu_alerts_sns_topic.arn
  protocol  = "email"
  endpoint  = var.email_for_alerts
}