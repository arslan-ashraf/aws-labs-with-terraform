#################################################################################
# US-East-1 Region - VPC, Internet Gateway, Subnet, Route Table, Security Group #
#################################################################################

resource "aws_vpc" "vpc_in_US_east" {
  provider = aws.region_US_east
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "vpc_in_US_east" }
}

resource "aws_internet_gateway" "internet_gateway_for_vpc_in_US_east" {
  vpc_id = aws_vpc.vpc_in_US_east.id
  tags = { Name = "internet_gateway_for_vpc_in_US_east" }
}

resource "aws_subnet" "subnet_in_US_east" {
  vpc_id            = aws_vpc.vpc_in_US_east.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  tags = { Name = "subnet_in_US_east" }
}

resource "aws_route_table" "route_table_for_subnet_in_US_east" {
  vpc_id = aws_vpc.vpc_in_US_east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_vpc_in_US_east.id
  }

  tags = { Name = "route_table_for_subnet_in_US_east" }

}

# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "route_table_association_subnet_US_east_vpc" {
  subnet_id      = aws_subnet.subnet_in_US_east.id
  route_table_id = aws_route_table.route_table_for_subnet_in_US_east.id
}

resource "aws_security_group" "security_group_US_east" {
  name     = "US-east-security-group"
  vpc_id   = aws_vpc.vpc_in_US_east.id
  tags     = { Name = "US-east-security-group" }
}

resource "aws_vpc_security_group_egress_rule" "allow_ping_out_rule_US_east" {
  description = "Allow only outbound ICMP echo requests (using ping)"

  security_group_id = aws_security_group.security_group_US_east.id
  cidr_ipv4         = "90.0.0.0/16" # where is the traffic going

  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ping_in_rule_US_east" {
  description = "Allow only inbound ICMP echo packets (using ping)"

  security_group_id = aws_security_group.security_group_US_east.id
  cidr_ipv4         = "90.0.0.0/16" # where is the traffic coming from

  # to allow ping but only from within VPC
  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}


#################################################################################
### Tokyo Region - VPC, Internet Gateway, Subnet, Route Table, Security Group ###
#################################################################################


resource "aws_vpc" "vpc_in_Tokyo" {
  provider = aws.region_Tokyo
  cidr_block = "90.0.0.0/16"
  tags       = { Name = "vpc_in_Tokyo" }
}

resource "aws_internet_gateway" "internet_gateway_for_vpc_in_Tokyo" {
  vpc_id = aws_vpc.vpc_in_Tokyo.id
  tags = { Name = "internet_gateway_for_vpc_in_Tokyo" }
}

resource "aws_subnet" "subnet_in_Tokyo" {
  vpc_id            = aws_vpc.vpc_in_Tokyo.id
  availability_zone = "apne1-az1"
  cidr_block        = "90.0.5.0/24"
  tags = { Name = "subnet_in_Tokyo" }
}

resource "aws_route_table" "route_table_for_subnet_in_Tokyo" {
  vpc_id = aws_vpc.vpc_in_Tokyo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_vpc_in_Tokyo.id
  }

  tags = { Name = "route_table_for_subnet_in_Tokyo" }

}

# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "route_table_association_subnet_Tokyo_vpc" {
  subnet_id      = aws_subnet.subnet_in_Tokyo.id
  route_table_id = aws_route_table.route_table_for_subnet_in_Tokyo.id
}

resource "aws_security_group" "security_group_Tokyo" {
  name     = "Tokyo-security-group"
  vpc_id   = aws_vpc.vpc_in_Tokyo.id
  tags     = { Name = "Tokyo-security-group" }
}

resource "aws_vpc_security_group_egress_rule" "allow_ping_out_rule_Tokyo" {
  description = "Allow only outbound ICMP echo requests (using ping)"

  security_group_id = aws_security_group.security_group_Tokyo.id
  cidr_ipv4         = "10.0.0.0/16" # where is the traffic going

  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ping_in_rule_Tokyo" {
  description = "Allow only inbound ICMP echo packets (using ping)"

  security_group_id = aws_security_group.security_group_Tokyo.id
  cidr_ipv4         = "10.0.0.0/16" # where is the traffic coming from

  # to allow ping but only from within VPC
  from_port = 8
  to_port   = 0

  ip_protocol = "icmp"
}