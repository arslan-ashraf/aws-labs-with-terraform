#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.main]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.main]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_node_group.main]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
# EBS CSI driver for persistent storage with Pod Identity authentication
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  depends_on = [
    aws_eks_node_group.main,
    aws_eks_pod_identity_association.ebs_csi_driver
  ]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [aws_eks_node_group.main]
}