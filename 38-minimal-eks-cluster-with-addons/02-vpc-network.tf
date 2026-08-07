resource "aws_vpc" "vpc_for_eks" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "vpc_for_eks" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_for_eks.id
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_for_eks.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb"                        = 1,      # required tag for AWS load balancer
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" # or shared
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_for_eks.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb"                        = 1,      # required tag for AWS load balancer
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" # or shared
  }
}

resource "aws_route_table" "route_table_eks_vpc" {
  vpc_id = aws_vpc.vpc_for_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


resource "aws_route_table_association" "public_subnet_a_assoc" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_eks_vpc.id
}

resource "aws_route_table_association" "public_subnet_b_assoc" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table_eks_vpc.id
}