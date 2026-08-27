# AWS Health Events
resource "aws_cloudwatch_event_rule" "karpenter_health_event" {
  name          = "${local.eks_cluster_name}_aws_health_events"
  event_pattern = jsonencode({
    source        = ["aws.health"]
    "detail-type" = ["AWS Health Event"]
  })

  tags = { Name = "${local.eks_cluster_name}-aws-health-events" }
}

resource "aws_cloudwatch_event_target" "karpenter_health_target" {
  rule      = aws_cloudwatch_event_rule.karpenter_health_event.name
  target_id = "KarpenterHealthTarget"
  arn       = aws_sqs_queue.karpenter_ec2_spot_interruption_queue.arn
}


# EC2 Spot Interruption Warning
resource "aws_cloudwatch_event_rule" "karpenter_ec2_spot_interrupt" {
  name          = "${local.eks_cluster_name}-ec2-spot-interruption-warning"
  event_pattern = jsonencode({
    source       = ["aws.ec2"]
    "detail-type" = ["EC2 Spot Instance Interruption Warning"]
  })

  tags = { Name = "${local.eks_cluster_name}-ec2-spot-interruption-warning" }
}

resource "aws_cloudwatch_event_target" "karpenter_spot_target" {
  rule      = aws_cloudwatch_event_rule.karpenter_ec2_spot_interrupt.name
  target_id = "KarpenterSpotTarget"
  arn       = aws_sqs_queue.karpenter_ec2_spot_interruption_queue.arn
}


# EC2 instance rebalance
resource "aws_cloudwatch_event_rule" "karpenter_ec2_instance_rebalance" {
  name          = "${local.eks_cluster_name}_karpenter_ec2_instance_rebalance"
  event_pattern = jsonencode({
    source       = ["aws.ec2"]
    "detail-type" = ["EC2 Instance Rebalance"]
  })

  tags = { Name = "${local.eks_cluster_name}_karpenter_ec2_instance_rebalance" }
}

resource "aws_cloudwatch_event_target" "karpenter_rebalance_target" {
  rule      = aws_cloudwatch_event_rule.karpenter_ec2_instance_rebalance.name
  target_id = "KarpenterRebalanceTarget"
  arn       = aws_sqs_queue.karpenter_ec2_spot_interruption_queue.arn
}


# EC2 Instance State-change Notification → SQS

resource "aws_cloudwatch_event_rule" "karpenter_instance_state" {
  name        = "${local.short_cluster}-k-state"
  description = "EC2 Instance State Change Notification → Karpenter SQS Queue"

  event_pattern = jsonencode({
    source       = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "karpenter_instance_state_target" {
  rule      = aws_cloudwatch_event_rule.karpenter_instance_state.name
  target_id = "KarpenterStateTarget"
  arn       = aws_sqs_queue.karpenter_ec2_spot_interruption_queue.arn
}