resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.example_vpc.id

  tags = { Name = "internet_gateway" }

}

resource "aws_subnet" "public_subnet" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "public_subnet" }
}

# create a route table and attach it to the internet gateway for all
# inbound and outbound traffic
resource "aws_route_table" "route_table_for_public_subnet" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = { Name = "route_table_for_public_subnet" }

}

# attach the route table to one of the subnets to make it public
# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "public_subnet_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_for_public_subnet.id
}