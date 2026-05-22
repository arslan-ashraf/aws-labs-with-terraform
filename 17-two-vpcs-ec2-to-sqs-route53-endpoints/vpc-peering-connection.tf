resource "aws_vpc_peering_connection" "ec2_to_sqs_interface_endpoint_connection" {
  region      = "us-east-1"               # region where this is defined
  vpc_id      = aws_vpc.vpc_for_ec2.id    # connection requester VPC

  # connection acceptor VPC
  peer_vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id   
  peer_region = "us-east-1"               # region of accecptor VPC
  tags        = { Name = "ec2_requesting_connection_to_sqs_interface_endpoint" }

  # auto_accept = bool    # only works when both VPCs are same account and region
}


resource "aws_vpc_peering_connection_accepter" "sqs_endpoint_vpc_peering_acceptor" {
  vpc_peering_connection_id = aws_vpc_peering_connection.ec2_to_sqs_interface_endpoint_connection.id
  auto_accept               = true
  tags                      = { Name = "sqs_interface_endpoint_accepting_connection_from_ec2_instance" }
}