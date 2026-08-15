# allocate elastic IP (EIP) for the nat gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway_for_main_vpc]

  tags = { Name = "nat_gateway_elastic_ip" }
}

locals {
  # get the name of the first public subnet, something like
  # public_subnet_c
  first_public_subnet = keys(local.public_subnets)[0]
}

# create a single NAT Gateway in any public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id  = aws_eip.nat_gateway_eip.id
  subnet_id      = aws_subnet.subnets_in_main_vpc[local.first_public_subnet].id

  tags = { Name = "nat_gateway_in_public_subnet" }

  # Explicit dependency to ensure proper ordering during creation/destruction
  depends_on = [aws_internet_gateway.internet_gateway_for_main_vpc]
}