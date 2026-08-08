# Karpenter Controller IAM Policy
# Reference: https://karpenter.sh/docs/reference/cloudformation/
# Source: https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.12.0/website/content/en/preview/getting-started/getting-started-with-karpenter/cloudformation.yaml
# This policy document combines all 6 Karpenter controller policies:
# 1. NodeLifecyclePolicy - EC2 instance and launch template lifecycle management
# 2. IAMIntegrationPolicy - IAM instance profile management
# 3. EKSIntegrationPolicy - EKS cluster discovery
# 4. InterruptionPolicy - SQS interruption queue access
# 5. ZonalShiftPolicy - Zonal Shift status access
# 6. ResourceDiscoveryPolicy - Read-only resource discovery

data "aws_iam_policy_document" "karpenter_controller" {

  # =============================================================================
  # NodeLifecyclePolicy - EC2 instance and launch template lifecycle management
  # =============================================================================

  # Allow RunInstances and CreateFleet on images, snapshots, security groups, subnets,
  # capacity reservations, and placement groups
  statement {
    sid = "AllowScopedEC2InstanceAccessActions"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}::image/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}::snapshot/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:security-group/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:subnet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:capacity-reservation/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:placement-group/*"
    ]
  }

  # Allow RunInstances and CreateFleet on launch templates owned by this cluster
  statement {
    sid = "AllowScopedEC2LaunchTemplateAccessActions"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:launch-template/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # Allow instance creation with proper tags
  statement {
    sid = "AllowScopedEC2InstanceActionsWithTags"
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:fleet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:volume/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:network-interface/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:launch-template/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:spot-instances-request/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.main.name]
    }
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # Allow tagging during resource creation
  statement {
    sid = "AllowScopedResourceCreationTagging"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:fleet/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:volume/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:network-interface/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:launch-template/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:spot-instances-request/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.main.name]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # Allow tagging existing instances
  statement {
    sid = "AllowScopedResourceTagging"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.main.name]
    }
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values   = ["eks:eks-cluster-name", "karpenter.sh/nodeclaim", "Name"]
    }
  }

  # Allow terminating instances and deleting launch templates
  statement {
    sid = "AllowScopedDeletion"
    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:instance/*",
      "arn:${data.aws_partition.current.partition}:ec2:${var.region}:*:launch-template/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  # =============================================================================
  # IAMIntegrationPolicy - IAM instance profile management
  # =============================================================================

  # Allow passing node role to EC2 instances
  statement {
    sid = "AllowPassingInstanceRole"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.eks_nodes.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"]
    }
  }

  # Allow creating instance profiles
  statement {
    sid = "AllowScopedInstanceProfileCreationActions"
    actions = [
      "iam:CreateInstanceProfile"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.main.name]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [var.region]
    }
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  # Allow tagging instance profiles
  statement {
    sid = "AllowScopedInstanceProfileTagActions"
    actions = [
      "iam:TagInstanceProfile"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [var.region]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = [aws_eks_cluster.main.name]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [var.region]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  # Allow managing instance profiles
  statement {
    sid = "AllowScopedInstanceProfileActions"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.main.name}"
      values   = ["owned"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [var.region]
    }
    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  # =============================================================================
  # EKSIntegrationPolicy - EKS cluster discovery
  # =============================================================================

  # Allow describing the EKS cluster
  statement {
    sid = "AllowAPIServerEndpointDiscovery"
    actions = [
      "eks:DescribeCluster"
    ]
    resources = [
      aws_eks_cluster.main.arn
    ]
  }

  # =============================================================================
  # InterruptionPolicy - SQS interruption queue access
  # =============================================================================

  # Allow Karpenter to consume messages from the interruption queue
  statement {
    sid = "AllowInterruptionQueueActions"
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.karpenter_interruption.arn
    ]
  }

  # =============================================================================
  # ZonalShiftPolicy - Zonal Shift status access
  # =============================================================================

  # Allow Karpenter to read zonal shift status for the cluster
  statement {
    sid = "AllowZonalShiftStatusReadOnly"
    actions = [
      "arc-zonal-shift:GetManagedResource"
    ]
    resources = [
      aws_eks_cluster.main.arn
    ]
  }

  # =============================================================================
  # ResourceDiscoveryPolicy - Read-only resource discovery
  # =============================================================================

  # Allow regional read actions for instance type and resource discovery
  statement {
    sid = "AllowRegionalReadActions"
    actions = [
      "ec2:DescribeCapacityReservations",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribePlacementGroups",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  # Allow SSM parameter read for AMI discovery
  statement {
    sid = "AllowSSMReadActions"
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${var.region}::parameter/aws/service/*"
    ]
  }

  # Allow pricing API for cost optimization
  statement {
    sid = "AllowPricingReadActions"
    actions = [
      "pricing:GetProducts"
    ]
    resources = ["*"]
  }

  # Allow listing instance profiles
  statement {
    sid = "AllowUnscopedInstanceProfileListAction"
    actions = [
      "iam:ListInstanceProfiles"
    ]
    resources = ["*"]
  }

  # Allow reading instance profiles
  statement {
    sid = "AllowInstanceProfileReadActions"
    actions = [
      "iam:GetInstanceProfile"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
    ]
  }

  # Allow describing instance status for health checks
  statement {
    sid = "AllowUnscopedEC2DescribeInstanceStatus"
    actions = [
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }
}
