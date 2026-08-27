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

  }

  statement {
    effect    = "Deny"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions   = ["sqs:*"]   # allow GetObject action
    resources = [aws_sqs_queue.ec2_spot_interruption_queue.arn]

    # restricts the "allow" and "actions"
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn" # but only if the sourceArn of the principal, ie: CloudFront's Arn
      values   = [aws_cloudfront_distribution.s3_ec2_group_distribution.arn] # has this arn
    }
  }
}

resource "aws_sqs_queue_policy" "ec2_spot_interruption_queue" {
  queue_url = aws_sqs_queue.ec2_spot_interruption_queue.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com"]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.ec2_spot_interruption_queue.arn
      },
      {
        Sid      = "DenyHTTP"
        Effect   = "Deny"
        Action   = "sqs:*"
        Resource = aws_sqs_queue.ec2_spot_interruption_queue.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
        Principal = "*"
      }
    ]
  })
}