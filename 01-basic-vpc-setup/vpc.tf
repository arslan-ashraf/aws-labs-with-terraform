terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC created with Terraform"
  }

  # instance_tenancy = "Optional"
  # enable_dns_support = "Optional"
  # enable_dns_hostnames = "Optional"
  # enable_classiclink = "Optional"
  # enable_classiclink_dns_support = "Optional"
}

resource "aws_subnet" "public_subnet_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.example_vpc.id

  # availability_zone_id = "Optional"
  # ipv6_cidr_block = "Optional"
  # map_public_ip_on_launch = "Optional"
  # assign_ipv6_address_on_creation = "Optional"
  # tags = "Optional"
}

resource "aws_subnet" "private_subnet_in_example_vpc" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.example_vpc.id
}


resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id
  # tags = "Optional"
}

resource "aws_route_table" "route_table_for_public_subnet_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

}

resource "aws_route_table_association" "route_table_association_public_subnet_example_vpc" {
  subnet_id      = aws_subnet.public_subnet_in_example_vpc.id
  route_table_id = aws_route_table.route_table_for_public_subnet_in_example_vpc.id
}