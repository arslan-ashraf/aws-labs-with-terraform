# # allocate elastic IP (EIP) for the nat gateway
# resource "aws_eip" "nat_gateway_eip" {
#   domain     = "vpc"
#   depends_on = [aws_internet_gateway.internet_gateway_for_main_vpc]

#   tags = { Name = "nat_gateway_elastic_ip" }
# }

# output "public_subnets" {
#   value = local.public_subnets
# }

# create a single NAT Gateway in any public subnet
# resource "aws_nat_gateway" "nat_gateway" {
#   public_subnets = keys(local.public_subnets)
#   allocation_id  = aws_eip.nat_gateway_eip.id
#   subnet_id      = aws_subnet.subnets_in_main_vpc[public_subnets[0]].id

#   tags = { Name = "nat_gateway_in_public_subnet" }

#   # Explicit dependency to ensure proper ordering during creation/destruction
#   depends_on = [aws_internet_gateway.internet_gateway_for_main_vpc]
# }