resource "aws_security_group" "security_group_private_ec2_instances" {
  name   = "security_group_private_ec2_instances"
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "security_group_private_ec2_instances" }
}

# allow traffic out to the NAT gateway
resource "aws_vpc_security_group_egress_rule" "egress_nat_gateway_rule" {
  security_group_id = aws_security_group.security_group_private_ec2_instances.id

  # Target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}

# allow EKS control plane to communicate with worker nodes
resource "aws_vpc_security_group_ingress_rule" "nodes_inbound_from_control_plane_rule" {
  security_group_id        = aws_security_group.security_group_private_ec2_instances.id
  source_security_group_id = var.cluster_control_plane_sg_id # The cluster's own SG

  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  
  description              = "Allow Kubelet communication from control plane"
}