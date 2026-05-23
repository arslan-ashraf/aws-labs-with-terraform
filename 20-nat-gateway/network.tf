resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id
  tags   = { Name = "internet_gateway_for_example_vpc" }
}


resource "aws_subnet" "public_subnet_for_nat_gateway" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "public_subnet_for_nat_gateway" }
}


resource "aws_subnet" "private_subnet_for_ec2_instance" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.6.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "private_subnet_for_ec2_instance" }
}

resource "aws_route_table" "route_table_for_private_subnet_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = { Name = "route_table_for_private_subnet_in_example_vpc" }

}

resource "aws_route_table_association" "route_table_association_public_subnet_example_vpc" {
  subnet_id      = aws_subnet.private_subnet_for_ec2_instance.id
  route_table_id = aws_route_table.route_table_for_private_subnet_in_example_vpc.id
}