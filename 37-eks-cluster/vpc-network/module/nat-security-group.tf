resource "aws_security_group" "security_group_for_NAT_instance" {
  name   = "security_group_for_NAT_instance"
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "security_group_for_NAT_instance" }
}

# allow private EC2 instances to reach the NAT instance
resource "aws_vpc_security_group_ingress_rule" "ingress_from_ec2_rule" {
  security_group_id = aws_security_group.security_group_for_NAT_instance.id

  # where is the traffic coming from
  # referenced_security_group_id also works but the private ec2
  # instance security group is required for that
  # referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id
  cidr_ipv4   = aws_vpc.main_vpc.cidr_block

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