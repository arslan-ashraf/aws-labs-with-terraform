resource "aws_sns_topic" "trigger_lambda_sns_topic" {
  name = "trigger_lambda_sns_topic"
}

resource "aws_sns_topic_subscription" "alert_by_email" {
  topic_arn = aws_sns_topic.trigger_lambda_sns_topic.arn
  protocol  = "email"
  endpoint  = 
}