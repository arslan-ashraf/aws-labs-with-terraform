# security group for the EKS cluster control plane
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