resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_in_example_vpc.id
  key_name                    = "key-for-ec2-connection"

  vpc_security_group_ids = [
    aws_security_group.security_group_public_traffic.id
  ]

  tags = { Name = "in_public_subnet_in_example_vpc" }

}

resource "aws_security_group" "security_group_public_traffic" {
  name   = "security-group-for-public-traffic"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "sg-for-public-traffic" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_traffic_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic coming from

  # to allow ingress traffic for ssh
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "engress_ping_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic going

  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}

resource "aws_key_pair" "deployer" {
  key_name   = "key-for-ec2-connection"
  public_key = file("~/.ssh/key-for-ec2-connection.pub")
}