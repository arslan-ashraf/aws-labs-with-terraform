resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  tags = { Name = "internet_gateway_for_example_vpc" }

}

# create multiple subnets with for_each loop
resource "aws_subnet" "subnets_in_example_vpc" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.example_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = each.value.cidr_block

  tags = { Name = "${each.key}_in_example_vpc" }
}

resource "aws_route_table" "route_table_for_public_subnet_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

  tags = { Name = "route_table_for_public_subnet_in_example_vpc" }

}

# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "route_table_association_public_subnet_example_vpc" {
  subnet_id      = aws_subnet.subnets_in_example_vpc["public_subnet"].id
  route_table_id = aws_route_table.route_table_for_public_subnet_in_example_vpc.id
}

# create multiple security groups with for_each loop
resource "aws_security_group" "mulitple_security_groups" {
  for_each = var.security_group_config
  name     = each.value.name
  vpc_id   = aws_vpc.example_vpc
  tags     = { Name = each.key }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_public_sg" {
  security_group_id = aws_security_group.multiple_security_groups["public_traffic_sg"].id
  cidr_ipv4         = "0.0.0.0/0" # where is the traffic coming from

  # to allow ingress traffic for ssh
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_private_sg" {
  security_group_id = aws_security_group.multiple_security_groups["private_traffic_sg"].id
  cidr_ipv4         = "10.0.0.0/16" # where is the traffic coming from, from within VPC

  # to allow ingress traffic for ssh but only from within VPC
  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "ping_connection_rule_private_sg" {
  security_group_id = aws_security_group.multiple_security_groups["private_traffic_sg"].id
  cidr_ipv4         = "10.0.0.0/16" # where is the traffic coming from, from within VPC

  # to allow ping but only from within VPC
  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}