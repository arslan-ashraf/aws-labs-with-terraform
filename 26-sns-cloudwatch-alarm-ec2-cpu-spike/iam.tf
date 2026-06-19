data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"

    actions = ["SNS:Publish"]


    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.ec2_cpu_alerts.arn
    ]
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.ec2_cpu_alerts.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}