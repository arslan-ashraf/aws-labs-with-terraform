data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"

    actions = ["SNS:Publish"]


    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.secret_accessed_alerts_topic.arn
    ]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.secret_accessed_alerts_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}