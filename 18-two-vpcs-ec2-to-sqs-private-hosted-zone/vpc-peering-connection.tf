# one VPC  making VPC peering connection request to another VPC
resource "aws_vpc_peering_connection" "EC2_to_SQS_interface_endpoint_connection" {
  region      = "us-east-1"               # region where this is defined
  vpc_id      = aws_vpc.vpc_for_ec2.id    # connection requester VPC
  # connection acceptor VPC
  peer_vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id   
  peer_region = "us-east-1"          # region of accecptor VPC
  tags        = { Name = "EC2_to_SQS_interface_endpoint_connection" }

  # auto_accept = bool    # only works when both VPCs are same account and region

  # # Options for the requester VPC
  # requester {
  #   allow_remote_vpc_dns_resolution = true
  # }

  # # Options for the accepter VPC
  # accepter {
  #   allow_remote_vpc_dns_resolution = true
  # }
}


# request receiving VPC accepting the peering connection from reqesting VPC
resource "aws_vpc_peering_connection_accepter" "vpc_peering_connection_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.EC2_to_SQS_interface_endpoint_connection.id
  auto_accept               = true
  tags                      = { Name = "vpc_peering_connection_accepter" }
}



resource "aws_vpc_peering_connection_options" "requester" {
  # vpc_peering_connection_id = aws_vpc_peering_connection.EC2_to_SQS_interface_endpoint_connection.id
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

}

resource "aws_vpc_peering_connection_options" "accepter" {
  # vpc_peering_connection_id = aws_vpc_peering_connection.EC2_to_SQS_interface_endpoint_connection.id
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.vpc_peering_connection_accepter.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

}