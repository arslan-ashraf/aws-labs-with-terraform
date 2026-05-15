resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

resource "aws_subnet" "private_subnet_for_ec2_instance" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "private_subnet_for_ec2_instance" }
}

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "security_group_for_ec2_instance" }
}