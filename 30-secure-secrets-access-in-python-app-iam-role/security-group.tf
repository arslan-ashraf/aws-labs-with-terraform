resource "aws_security_group" "security_group_public_traffic" {
  name   = "security-group-for-public-traffic"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "sg-for-public-traffic" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic coming from

  # to allow ingress traffic for ssh
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_python_server_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic coming from

  # to allow visiting the python server hosted on <server_public_ip>:8000
  from_port = 8000
  to_port   = 8000

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_to_internet_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic going

  ip_protocol = "-1"
}