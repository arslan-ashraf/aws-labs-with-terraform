resource "aws_sns_topic" "trigger_lambda_sns_topic" {
  name = "trigger_lambda_sns_topic"
}

resource "aws_sns_topic_subscription" "lambda_sns_topic_subscription" {
  topic_arn = aws_sns_topic.trigger_lambda_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.target_lambda.arn
}