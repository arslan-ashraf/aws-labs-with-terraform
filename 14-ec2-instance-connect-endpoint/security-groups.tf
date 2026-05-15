# this file has two security groups, one with an ingress ssh rule and the other
# with a egress ssh rule

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  
  # where is the traffic coming from
  cidr_ipv4 = aws_security_group.private_subnet_for_ec2_instance_endpoint.cidr_ipv4
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}



resource "aws_security_group" "security_group_for_ec2_instance_endpoint" {
  name   = "security_group_for_ec2_instance_endpoint"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance_endpoint" }
}

resource "aws_vpc_security_group_egress_rule" "egress_ssh_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id

  # where is the traffic going
  cidr_ipv4 = aws_subnet.private_subnet_for_ec2_instance.cidr_ipv4 
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}