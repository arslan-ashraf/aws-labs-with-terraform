##################################################################
# this is the role that EC2 instances (which have been provisioned
# by Karpenter) use to find and become part of the EKS Cluster
##################################################################

data "aws_iam_policy_document" "karpenter_node_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "karpenter_node_role" {
  name               = "karpenter_node_role"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_node_policies_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = each.value
}