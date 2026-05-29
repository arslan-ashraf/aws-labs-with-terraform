# VPC in US-east region making VPC peering connection request to 
# VPC in Tokyo region
resource "aws_vpc_peering_connection" "connection_US_east_to_Tokyo" {
  region      = "us-east-1"               # region where this is defined
  vpc_id      = aws_vpc.vpc_in_US_east.id # connection requester VPC
  peer_vpc_id = aws_vpc.vpc_in_Tokyo.id   # connection acceptor VPC
  peer_region = "ap-northeast-1"          # region of accecptor VPC
  tags        = { Name = "US_east_requesting_connection_to_Tokyo" }

  # auto_accept = bool    # only works when both VPCs are same account and region
}


# VPC in Tokyo region accepting the peering connection from VPC in US-east region
resource "aws_vpc_peering_connection_accepter" "vpc_peering_connection_accepter_Tokyo" {
  provider                  = aws.region_Tokyo
  vpc_peering_connection_id = aws_vpc_peering_connection.connection_US_east_to_Tokyo.id
  auto_accept               = true
  tags                      = { Name = "Tokyo_accepting_connection_from_US_east" }
}