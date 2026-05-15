resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }

  # enable_dns_support (default true), controls if public & private DNS hostname
  # resolution is possible using the AWS provided DNS server which runs at
  # VPC base cidr + 2 and the IP address 169.254.169.253, this is required to use
  
  enable_dns_support = true 
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
resource "aws_security_group" "multiple_security_groups" {
  for_each = var.security_group_config
  name     = each.value.name
  vpc_id   = aws_vpc.example_vpc.id
  tags     = { Name = each.key }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_public_sg" {
  description = "Allow SSH connection from anywhere"

  security_group_id = aws_security_group.multiple_security_groups["public_traffic_sg"].id
  
  cidr_ipv4 = "0.0.0.0/0" # where is the traffic coming from
  from_port = 22
  to_port   = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_ping_out_rule_public_sg" {
  description = "Allow only outbound ICMP echo requests (using ping)"

  security_group_id = aws_security_group.multiple_security_groups["public_traffic_sg"].id
  
  cidr_ipv4   = "0.0.0.0/0" # where is the traffic coming from
  from_port   = 8
  to_port     = 0
  ip_protocol = "icmp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_connection_rule_private_sg" {
  description = "Allow only ssh connection on port 22 from within VPC"

  security_group_id = aws_security_group.multiple_security_groups["private_traffic_sg"].id

  cidr_ipv4   = "10.0.0.0/16" # where is the traffic coming from, from within VPC
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