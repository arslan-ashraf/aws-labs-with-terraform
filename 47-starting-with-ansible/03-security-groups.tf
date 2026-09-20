# create multiple security groups with for_each loop
resource "aws_security_group" "multiple_security_groups" {
  for_each = var.security_group_config
  name     = each.value.name
  vpc_id   = aws_vpc.example_vpc.id
  tags     = { Name = each.key }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_public_sg" {
  description = "Allow SSH connection to public EC2 from anywhere"

  security_group_id = aws_security_group.multiple_security_groups["public_traffic_sg"].id
  
  cidr_ipv4 = "0.0.0.0/0" # where is the traffic coming from
  from_port = 22
  to_port   = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_internet_rule" {
  description = "Allow outbound internet traffic from public EC2"

  security_group_id = aws_security_group.multiple_security_groups["public_traffic_sg"].id
  
  # target destination
  cidr_ipv4 = "0.0.0.0/0"

  # all protocols
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_private_sg" {
  description = "Allow only SSH connection on port 22 from within VPC"

  security_group_id = aws_security_group.multiple_security_groups["private_traffic_sg"].id

  # where the traffic is coming from, from within the VPC
  cidr_ipv4   = aws_vpc.example_vpc.cidr_block

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "ping_connection_rule_private_sg" {
  description = "Allow only inbound ICMP echo packets (using ping) from within VPC"

  security_group_id = aws_security_group.multiple_security_groups["private_traffic_sg"].id
  
  cidr_ipv4   = "10.0.0.0/16" # where is the traffic coming from, from within VPC
  from_port   = 8
  to_port     = 0
  ip_protocol = "icmp"
}