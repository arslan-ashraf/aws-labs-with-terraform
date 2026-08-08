# Karpenter Interruption Handling
# SQS queue and EventBridge rules for EC2 spot interruption, rebalance,
# state change, health events, and capacity reservation interruption notifications
# Reference: https://karpenter.sh/docs/reference/cloudformation/

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue
resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = aws_eks_cluster.main.name
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy
resource "aws_sqs_queue_policy" "karpenter_interruption" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy = jsonencode({
    Id      = "EC2InterruptionPolicy"
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["events.amazonaws.com", "sqs.amazonaws.com"]
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.karpenter_interruption.arn
      },
      {
        Sid       = "DenyHTTP"
        Effect    = "Deny"
        Action    = "sqs:*"
        Resource  = aws_sqs_queue.karpenter_interruption.arn
        Principal = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# EventBridge rules to forward interruption events to the SQS queue

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule
resource "aws_cloudwatch_event_rule" "scheduled_change" {
  name = "${var.name}-karpenter-scheduled-change"
  event_pattern = jsonencode({
    source      = ["aws.health"]
    detail-type = ["AWS Health Event"]
  })
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target
resource "aws_cloudwatch_event_target" "scheduled_change" {
  rule = aws_cloudwatch_event_rule.scheduled_change.name
  arn  = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name = "${var.name}-karpenter-spot-interruption"
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "spot_interruption" {
  rule = aws_cloudwatch_event_rule.spot_interruption.name
  arn  = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "rebalance" {
  name = "${var.name}-karpenter-rebalance"
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance Rebalance Recommendation"]
  })
}

resource "aws_cloudwatch_event_target" "rebalance" {
  rule = aws_cloudwatch_event_rule.rebalance.name
  arn  = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name = "${var.name}-karpenter-instance-state-change"
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "instance_state_change" {
  rule = aws_cloudwatch_event_rule.instance_state_change.name
  arn  = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "capacity_reservation_interruption" {
  name = "${var.name}-karpenter-capacity-reservation-interruption"
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Capacity Reservation Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "capacity_reservation_interruption" {
  rule = aws_cloudwatch_event_rule.capacity_reservation_interruption.name
  arn  = aws_sqs_queue.karpenter_interruption.arn
}
