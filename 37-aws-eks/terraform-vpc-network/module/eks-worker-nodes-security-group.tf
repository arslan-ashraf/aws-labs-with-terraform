resource "aws_security_group" "eks_worker_nodes_security_group" {
  name   = "eks_worker_nodes_security_group"
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "eks_worker_nodes_security_group" }
}

# allow traffic out to the NAT gateway
resource "aws_vpc_security_group_egress_rule" "egress_nat_gateway_rule" {
  security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  # Target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}


# allow nodes to communicate with each other for pod networking and cluster DNS
resource "aws_security_group_ingress_rule" "nodes_internal_communication" {
  security_group_id            = aws_security_group.eks_worker_nodes_security_group.id

  # where the traffic is coming from
  referenced_security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  from_port                = 0
  to_port                  = 65535

  protocol                 = "-1"
}

# Allow cluster control plane to reach kubelet, webhooks, and other node services
resource "aws_security_group_rule" "nodes_ingress_from_cluster" {
  description              = "Allow cluster to communicate with nodes"
  
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
}


# allow EKS control plane to communicate with worker nodes
resource "aws_vpc_security_group_ingress_rule" "nodes_inbound_from_control_plane_rule" {
  security_group_id        = aws_security_group.eks_worker_nodes_security_group.id
  
  # where the traffic is coming from
  referenced_security_group_id = aws_security_group.eks_cluster.id

  from_port                = 443
  to_port                  = 65535
  protocol                 = "tcp"
  
  description              = "Allow Kubelet communication from control plane"
}