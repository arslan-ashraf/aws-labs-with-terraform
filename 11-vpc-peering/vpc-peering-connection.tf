# EC2 in VPC in US-east region making VPC peering connection request
# to EC2 in VPC in Tokyo region
resource "aws_vpc_peering_connection" "vpc_peering_connection_US_east_to_Tokyo" {
  region      = aws.region_US_east          # region where this is defined
  vpc_id      = aws_vpc.vpc_in_US_east.id   # connection requester VPC
  peer_vpc_id = aws_vpc.vpc_in_Tokyo.id     # connection acceptor VPC
  peer_region = aws.region_Tokyo            # region of accecptor VPC
  tags        = { Name = "US_east_connecting_to_Tokyo" }

  # auto_accept = bool    # only works when both VPCs are same account and region
}