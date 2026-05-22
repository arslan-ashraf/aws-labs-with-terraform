#########################################################################
####################### VPC FOR EC2 & SUBNETS  ##########################
#########################################################################

resource "aws_vpc" "vpc_for_ec2" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "vpc_for_ec2" }
}

# to allow SSH into the instance
resource "aws_internet_gateway" "internet_gateway_for_vpc_for_ec2" {
  vpc_id = aws_vpc.vpc_for_ec2.id

  tags = { Name = "internet_gateway_for_vpc_for_ec2" }

}

resource "aws_subnet" "public_subnet_for_ec2_instance" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.10.0/24"
  vpc_id            = aws_vpc.vpc_for_ec2.id

  tags = { Name = "public_subnet_for_ec2_instance" }
}

resource "aws_route_table" "route_table_for_public_subnet_in_vpc_for_ec2" {
  vpc_id = aws_vpc.vpc_for_ec2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_vpc_for_ec2.id
  }

  route {
    cidr_block = aws_vpc.vpc_for_sqs_interface_endpoint.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.ec2_to_sqs_interface_endpoint_connection.id
  }

  tags   = { Name = "route_table_for_public_subnet_in_vpc_for_ec2" }
}

resource "aws_route_table_association" "route_table_association_public_subnet_vpc_for_ec2" {
  subnet_id      = aws_subnet.public_subnet_for_ec2_instance.id
  route_table_id = aws_route_table.route_table_for_public_subnet_in_vpc_for_ec2.id
}

resource "aws_subnet" "dummy_subnet_in_vpc_for_ec2" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.11.0/24"
  vpc_id            = aws_vpc.vpc_for_ec2.id

  tags = { Name = "dummy_subnet_in_vpc_for_ec2" }
}


#########################################################################
############# VPC FOR SQS INTERFACE ENDPOINT & SUBNETS  #################
#########################################################################

resource "aws_vpc" "vpc_for_sqs_interface_endpoint" {
  cidr_block           = "90.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "vpc_for_sqs_interface_endpoint" }
}

resource "aws_subnet" "private_subnet_for_sqs_interface_endpoint" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.7.0/24"
  vpc_id            = aws_vpc.vpc_for_sqs_interface_endpoint.id

  tags = { Name = "private_subnet_for_sqs_interface_endpoint" }
}

resource "aws_route_table" "rtb_for_private_subnet_in_vpc_for_sqs_interface_endpoint" {
  vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id

  route {
    cidr_block = aws_vpc.vpc_for_ec2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.ec2_to_sqs_interface_endpoint_connection.id
  }

  tags   = { Name = "route_table_for_public_subnet_in_vpc_for_ec2" }
}

resource "aws_route_table_association" "route_table_association_private_subnet_vpc_for_sqs_endpoint" {
  subnet_id      = aws_subnet.private_subnet_for_sqs_interface_endpoint.id
  route_table_id = aws_route_table.rtb_for_private_subnet_in_vpc_for_sqs_interface_endpoint.id
}

resource "aws_subnet" "dummy_subnet_in_vpc_for_sqs_interface_endpoint" {
  availability_zone = "us-east-1a"
  cidr_block        = "90.0.11.0/24"
  vpc_id            = aws_vpc.vpc_for_sqs_interface_endpoint.id

  tags = { Name = "dummy_subnet_in_vpc_for_sqs_interface_endpoint" }
}