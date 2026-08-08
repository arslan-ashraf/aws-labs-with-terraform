#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# EKS Cluster Security Group (Control Plane)
resource "aws_security_group" "eks_cluster" {
  name        = "${var.name}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = module.vpc.vpc.id
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow worker nodes to communicate with the cluster API server
resource "aws_security_group_rule" "cluster_ingress_from_nodes" {
  description              = "Allow nodes to communicate with cluster API"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  type                     = "ingress"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow cluster to reach AWS APIs and services over HTTPS
resource "aws_security_group_rule" "cluster_egress_https" {
  description       = "HTTPS egress for cluster"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  type              = "egress"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow cluster to communicate with worker nodes (kubelet, logs, exec, webhooks)
resource "aws_security_group_rule" "cluster_egress_to_nodes" {
  description              = "Allow cluster to communicate with nodes"
  from_port                = 443
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  type                     = "egress"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# EKS Worker Nodes Security Group (Data Plane)
resource "aws_security_group" "eks_nodes" {
  name        = "${var.name}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc.id

  tags = {
    "karpenter.sh/discovery" = "${var.name}-cluster"
  }
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Node-to-node communication for pod networking and cluster DNS
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow cluster control plane to reach kubelet, webhooks, and other node services
resource "aws_security_group_rule" "nodes_ingress_from_cluster" {
  description              = "Allow cluster to communicate with nodes"
  from_port                = 443
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# Allow nodes to pull images, reach AWS APIs, and communicate externally
resource "aws_security_group_rule" "nodes_egress" {
  description       = "Allow all outbound traffic from nodes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  type              = "egress"
  #checkov:skip=CKV_AWS_382: Ensure no security groups allow egress from 0.0.0.0:0 to port -1
  #reason-for-skip: EKS worker nodes require outbound access for image pulls, AWS API calls, and DNS resolution
}