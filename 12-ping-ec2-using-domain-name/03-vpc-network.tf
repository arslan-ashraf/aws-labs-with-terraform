resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }

  # enable_dns_support (default true), controls if public & private DNS hostname
  # resolution is possible using the AWS provided DNS server which runs at
  # VPC base cidr + 2 and the IP address 169.254.169.253, this is required to 
  # resolve domain names within the VPC and to use Route53 private hosted zone
  # which holds the database records of domain names such as 
  # fklrj34wj-us-east-1.ec2.amazonaws.com to IP address
  enable_dns_support = true 

  # enable_dns_hostnames (default false), ensures EC2 instances with public IP 
  # addresses receive public DNS hostnames, however, if only private DNS hostnames
  # are desired, still set both parameters to true and avoid elastic IP addresses
  # with ENI, use private subnets (no internet gateway connection), turn off receive
  # public IP address when launching an EC2 instance by setting
  # associate_public_ip_address = false, AWS only generates a public DNS hostname
  # if the instance has a public IP address
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "internet_gateway_for_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  tags = { Name = "internet_gateway_for_example_vpc" }

}

# create multiple subnets with for_each loop
resource "aws_subnet" "subnets_in_example_vpc" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.example_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = each.value.cidr_block

  tags = { Name = "${each.key}_in_example_vpc" }
}

resource "aws_route_table" "route_table_for_public_subnet_in_example_vpc" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_for_example_vpc.id
  }

  tags = { Name = "route_table_for_public_subnet_in_example_vpc" }

}

# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "route_table_association_public_subnet_example_vpc" {
  subnet_id      = aws_subnet.subnets_in_example_vpc["public_subnet"].id
  route_table_id = aws_route_table.route_table_for_public_subnet_in_example_vpc.id
}