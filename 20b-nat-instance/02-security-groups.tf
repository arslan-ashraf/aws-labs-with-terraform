#########################################################################
##################### EC2 SECURITY GROUP & RULES ########################
#########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
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


########################################################################
################## EC2 ENDPOINT SECURITY GROUP & RULES #################
########################################################################


resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
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


########################################################################
################## NAT INSTANCE SECURITY GROUP & RULES #################
########################################################################


resource "aws_security_group" "security_group_for_NAT_instance" {
  name   = "security_group_for_NAT_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_NAT_instance" }
}

# allow private EC2 instance to reach NAT instance
resource "aws_vpc_security_group_ingress_rule" "ingress_from_ec2_rule" {
  security_group_id = aws_security_group.security_group_for_NAT_instance.id

  # where is the traffic coming from
  # referenced_security_group_id also works but the private ec2
  # instance security group is required for that
  # referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id
  cidr_ipv4   = aws_vpc.example_vpc.cidr_block

  ip_protocol = "-1"
}

# allow NAT instance traffic out to the internet
resource "aws_vpc_security_group_egress_rule" "egress_internet_rule" {
  security_group_id = aws_security_group.security_group_for_NAT_instance.id

  # Target destination
  cidr_ipv4   = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}

# allow SSH into NAT instance
resource "aws_vpc_security_group_ingress_rule" "ingress_SSH_rule" {
  security_group_id = aws_security_group.security_group_for_NAT_instance.id

  # where is the traffic coming from
  cidr_ipv4   = "0.0.0.0/0"

  from_port   = 22
  to_port     = 22

  ip_protocol = "tcp"
}