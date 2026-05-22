########################################
# Transit Gateway US East
########################################

resource "aws_ec2_transit_gateway" "transit_gateway_US_east" {
  provider = aws.region_US_east

  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit_gateway_US_east"
  }
}

########################################
# Attach US East VPC to US East Transit gateway
########################################

resource "aws_ec2_transit_gateway_vpc_attachment" "US_East_VPC_transit_gateway_attachment" {
  provider = aws.region_US_east

  subnet_ids         = [aws_subnet.subnet_in_US_east.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_US_east.id
  vpc_id             = aws_vpc.vpc_in_US_east.id

  tags = {
    Name = "US_East_VPC_transit_gateway_attachment"
  }
}


########################################
# Transit Gateway Tokyo
########################################

resource "aws_ec2_transit_gateway" "transit_gateway_Tokyo" {
  provider = aws.region_Tokyo

  amazon_side_asn                 = 64513
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "transit_gateway_Tokyo"
  }
}


########################################
# Attach Tokyo VPC to Tokyo Transit gateway
########################################

resource "aws_ec2_transit_gateway_vpc_attachment" "Tokyo_VPC_transit_gateway_attachment" {
  provider = aws.region_Tokyo

  subnet_ids         = [aws_subnet.subnet_in_Tokyo.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_Tokyo.id
  vpc_id             = aws_vpc.vpc_in_Tokyo.id

  tags = {
    Name = "Tokyo_VPC_transit_gateway_attachment"
  }
}

########################################
# Inter-region TGW Peering
########################################

resource "aws_ec2_transit_gateway_peering_attachment" "US_East_Tokyo_tgw_peering" {
  provider = aws.region_US_east

  transit_gateway_id      = aws_ec2_transit_gateway.transit_gateway_US_east.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.transit_gateway_Tokyo.id
  peer_region             = "ap-northeast-1"

  tags = {
    Name = "US_East_Tokyo_tgw_peering"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peer_accept" {
  provider = aws.region_Tokyo

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.US_East_Tokyo_tgw_peering.id

  tags = {
    Name = "tgw_peer_accept"
  }
}

########################################
# TGW Route Tables
########################################

resource "aws_ec2_transit_gateway_route" "route_US_East_to_Tokyo" {
  provider = aws.region_US_east

  destination_cidr_block         = aws_vpc.vpc_in_Tokyo.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway_US_east.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.US_East_Tokyo_tgw_peering.id
}

resource "aws_ec2_transit_gateway_route" "route_Tokyo_to_US_East" {
  provider = aws.region_Tokyo

  destination_cidr_block         = aws_vpc.vpc_in_US_east.cidr_block
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway_Tokyo.association_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.US_East_Tokyo_tgw_peering.id
}