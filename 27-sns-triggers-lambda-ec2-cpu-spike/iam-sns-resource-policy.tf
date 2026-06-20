data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"

    actions = ["SNS:Publish"]


    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [aws_sns_topic.trigger_lambda_sns_topic.arn]
  }
}

# SNS resource policy that allows CloudWatch to notify SNS if a 
# CloudWatch alarm is triggered
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.trigger_lambda_sns_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}