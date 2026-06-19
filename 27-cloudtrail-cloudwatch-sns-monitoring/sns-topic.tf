resource "aws_sns_topic" "secret_accessed_alerts_topic" {
  name = "secret_accessed_alerts_topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.secret_accessed_alerts_topic.arn
  protocol  = "email"
  endpoint  = var.email_for_alerts
}