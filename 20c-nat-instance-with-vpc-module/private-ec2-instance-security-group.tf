resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = module.vpc_network_module.vpc_id
  tags   = { Name = "security_group_for_ec2_instance" }
}


# allow SSH traffic in from the EC2 instance connect endpoint
resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

# allow traffic out to the NAT gateway
resource "aws_vpc_security_group_egress_rule" "egress_nat_gateway_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # Target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}

# for testing only, allow NAT instance to ping to the 
# private EC2 instance
resource "aws_vpc_security_group_ingress_rule" "ingress_from_NAT_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  cidr_ipv4 = "10.0.0.0/16"

  ip_protocol = "-1"
}



###############################################################
######### PRIVATE EC2 INSTANCE CONNECT SECURITY GROUP #########
###############################################################



resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = module.vpc_network_module.vpc_id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

# send SSH traffic out to the EC2 instance
resource "aws_vpc_security_group_egress_rule" "egress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance_endpoint.id

  # Target destination
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

