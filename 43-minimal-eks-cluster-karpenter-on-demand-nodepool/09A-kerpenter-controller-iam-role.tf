##############################################################
# this is the role that Karpenter uses to provision the nodes
##############################################################

data "aws_iam_policy_document" "karpenter_controller_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]  
  }
}

resource "aws_iam_role" "karpenter_controller_role" {
  name               = "karpenter_controller_role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume.json
}