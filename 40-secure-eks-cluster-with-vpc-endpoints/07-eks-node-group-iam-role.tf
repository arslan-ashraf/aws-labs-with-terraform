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

resource "aws_iam_role" "eks_node_group_role" {
  name               = "eks_node_group_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy_document.json
}


# AmazonEKSWorkerNodePolicy allows nodes in the node group to be able 
# to join the EKS cluster
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# AmazonEKS_CNI_Policy allows the VPC CNI plugin installed on worker
# nodes the necessary permissions to manage network configurations 
# for pods, it allows the CNI to list, describe, attach, and modify
# ENIs and IP addresses on your EC2 worker nodes
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# AmazonEC2ContainerRegistryReadOnly grants nodes permission to
# pull images from Amazon ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# SSM access since there is no bastion host or NAT
resource "aws_iam_role_policy_attachment" "node_AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam:aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node.name
}
