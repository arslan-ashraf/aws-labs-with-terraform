resource "aws_security_group" "eks_worker_nodes_security_group" {
  name   = "eks_worker_nodes_security_group"
  vpc_id = data.terraform_remote_state.vpc_network.outputs.vpc_id
  tags   = { Name = "eks_worker_nodes_security_group" }
  depends_on = [aws_eks_node_group.private_nodes]
}

# allow traffic out to the internet through NAT gateway
resource "aws_vpc_security_group_egress_rule" "egress_nat_gateway_rule" {
  security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  # Target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
  depends_on  = [aws_security_group.eks_worker_nodes_security_group]
}


# allow nodes to communicate with each other for pod networking and cluster DNS
resource "aws_vpc_security_group_ingress_rule" "nodes_internal_communication" {
  security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  # where the traffic is coming from
  referenced_security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  # from_port = 0
  # to_port   = 65535

  ip_protocol = "-1"
  depends_on  = [aws_security_group.eks_worker_nodes_security_group]
}

# allow EKS control plane to communicate with worker nodes
# to reach kubelet, webhooks, and other node services
resource "aws_vpc_security_group_ingress_rule" "nodes_inbound_from_control_plane_rule" {
  security_group_id = aws_security_group.eks_worker_nodes_security_group.id

  # where the traffic is coming from
  referenced_security_group_id = aws_security_group.eks_cluster_security_group.id

  # from_port   = 443
  # to_port     = 65535

  from_port   = 0
  to_port     = 65535
  ip_protocol = "tcp"
  depends_on  = [aws_security_group.eks_worker_nodes_security_group]
}