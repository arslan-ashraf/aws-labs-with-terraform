locals {
  common_tags = {
    created_with = "Terraform"
    purpose      = "learning"
  }
}


# create vpc
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, { Name = "example_vpc" })
}

# create internet gateway for the vpc
resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  tags = merge(local.common_tags, {
    Name = "internet_gateway_for_example_vpc"
  })

}

# create a subnet inside the vpc
resource "aws_subnet" "public_subnet_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.5.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = merge(local.common_tags, {
    Name = "public_subnet_in_example_vpc"
  })
}

# create a route table and attach it to the internet gateway for all
# inbound and outbound traffic
resource "aws_route_table" "route_table_for_public_subnet_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

  tags = {
    Name = "route_table_for_public_subnet_in_example_vpc"
  }

}

# attach the route table to one of the subnets to make it public
resource "aws_route_table_association" "route_table_association_public_subnet_example_vpc" {
  subnet_id      = aws_subnet.public_subnet_in_example_vpc.id
  route_table_id = aws_route_table.route_table_for_public_subnet_in_example_vpc.id
}