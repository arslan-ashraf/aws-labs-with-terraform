resource "aws_sqs_queue" "ec2_spot_interruption_queue" {
  name                      = "ec2_spot_interruption_queue_for_${local.eks_cluster_name}"
  
  # EC2 spot interruption is at most 2 minutes (120 seconds)
  # and then AWS will take those instances back, so we must respond
  # in at most 120 seconds or else the message is meaningless
  message_retention_seconds = 120 # seconds
  sqs_managed_sse_enabled   = true
  fifo_queue                = false

  tags = { Name = "ec2_spot_interruption_queue_for_${local.eks_cluster_name}" }
}

# define the resource based policy for the queue
data "aws_iam_policy_document" "sqs_resource_policy" {
  statement {
    effect    = "Allow"

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ec2_spot_interruption_queue.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [
        aws_cloudwatch_event_rule.karpenter_spot_interruption.arn
      ]
    }

  }

  statement {
    effect    = "Deny"

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.ec2_spot_interruption_queue.arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_sqs_queue_policy" "ec2_spot_interruption_queue" {
  queue_url = aws_sqs_queue.ec2_spot_interruption_queue.url
  policy = data.aws_iam_policy_document.sqs_resource_policy.json
}