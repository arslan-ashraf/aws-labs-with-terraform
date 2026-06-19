resource "aws_sns_topic" "secret_accessed_alerts" {
  name = "secret_accessed_alerts"
}

resource "aws_sns_topic_subscription" "alert_by_email" {
  topic_arn = aws_sns_topic.secret_accessed_alerts.arn
  protocol  = "email"
  endpoint  = var.email_for_alerts
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"

    actions = ["SNS:Publish"]


    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.secret_accessed_alerts.arn
    ]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.secret_accessed_alerts.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}