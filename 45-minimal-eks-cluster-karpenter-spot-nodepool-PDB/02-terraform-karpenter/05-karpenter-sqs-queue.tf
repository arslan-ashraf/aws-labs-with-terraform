resource "aws_sqs_queue" "ec2_spot_interruption_queue" {
  name                      = "ec2_spot_interruption_queue_for_${local.eks_cluster_name}"
  
  # EC2 spot interruption is at most 2 minutes (120 seconds)
  # and then AWS will take those instances back, so we must respond
  # in at most 120 seconds or else the message is meaningless
  message_retention_seconds = 120 # seconds
  sqs_managed_sse_enabled   = true
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