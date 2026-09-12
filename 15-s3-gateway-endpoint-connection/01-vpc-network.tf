resource "aws_vpc" "example_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "example_vpc" }
}

resource "aws_subnet" "private_subnet_for_ec2_instance" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "private_subnet_for_ec2_instance" }
}

resource "aws_route_table" "route_table_for_ec2_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "route_table_for_ec2_subnet" }
}

resource "aws_route_table_association" "route_table_association_ec2_subnet_example_vpc" {
  subnet_id      = aws_subnet.private_subnet_for_ec2_instance.id
  route_table_id = aws_route_table.route_table_for_ec2_subnet.id
}

resource "aws_subnet" "private_subnet_for_ec2_instance_endpoint" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.6.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "private_subnet_for_ec2_instance_endpoint" }
}