# security group for the EKS cluster control plane
resource "aws_security_group" "eks_cluster_security_group" {
  name        = "security_group_for_${var.eks_cluster_name}"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main_vpc.id
}

# allow worker nodes to communicate with the control plane API server
resource "aws_security_group_ingress_rule" "cluster_ingress_from_nodes" {
  security_group_id        = aws_security_group.eks_cluster_security_group.id

  source_security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
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