# allocate elastic IP (EIP) for the nat gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway_for_example_vpc]

  tags = { Name = "nat_gateway_eip" }
}

# create the NAT Gateway in public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet_for_nat_gateway.id

  tags = { Name = "nat_gateway" }

  # Explicit dependency to ensure proper ordering during creation/destruction
  depends_on = [aws_internet_gateway.internet_gateway_for_example_vpc]
}