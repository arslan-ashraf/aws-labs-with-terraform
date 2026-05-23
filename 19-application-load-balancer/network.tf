resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id
  tags = { Name = "internet_gateway_for_example_vpc" }
}


#########################################################################
############## SUNBET & ROUTE TABLE FOR EC2 INSTANCE 1 ##################
#########################################################################

resource "aws_subnet" "public_subnet_1_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "public_subnet_1_in_example_vpc" }
  
}

resource "aws_route_table" "route_table_for_public_subnet_1_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

  tags = { Name = "route_table_for_public_subnet_1_in_example_vpc" }

}

resource "aws_route_table_association" "route_table_association_public_subnet_1_example_vpc" {
  subnet_id      = aws_subnet.public_subnet_1_in_example_vpc.id
  route_table_id = aws_route_table.route_table_for_public_subnet_1_in_example_vpc.id
}


#########################################################################
############## SUNBET & ROUTE TABLE FOR EC2 INSTANCE 2 ##################
#########################################################################

resource "aws_subnet" "public_subnet_2_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "public_subnet_2_in_example_vpc" }
  
}

resource "aws_route_table" "route_table_for_public_subnet_2_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

  tags = { Name = "route_table_for_public_subnet_2_in_example_vpc" }

}

resource "aws_route_table_association" "route_table_association_public_subnet_2_example_vpc" {
  subnet_id      = aws_subnet.public_subnet_2_in_example_vpc.id
  route_table_id = aws_route_table.route_table_for_public_subnet_2_in_example_vpc.id
}


#########################################################################
############### SUNBET & ROUTE TABLE FOR LOAD BALANCER ##################
#########################################################################

resource "aws_subnet" "public_subnet_for_load_balancer_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  tags = { Name = "public_subnet_for_load_balancer_in_example_vpc" }
  
}