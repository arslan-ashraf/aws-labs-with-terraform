data "aws_iam_policy_document" "ec2_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "eks_nodegroup_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy_document.json
}

# ------------------------------------------------------------------------------
# IAM Policy Attachment: AmazonEKSWorkerNodePolicy
# Grants basic node group access to the EKS cluster
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# ------------------------------------------------------------------------------
# IAM Policy Attachment: AmazonEKS_CNI_Policy
# Allows nodes to manage networking (ENIs) via the VPC CNI plugin
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ------------------------------------------------------------------------------
# IAM Policy Attachment: AmazonEC2ContainerRegistryReadOnly
# Grants nodes permission to pull images from Amazon ECR
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_nodegroup_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}