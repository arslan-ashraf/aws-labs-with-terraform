resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

resource "aws_vpc_security_group_egress_rule" "egress_ping_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic going

  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}