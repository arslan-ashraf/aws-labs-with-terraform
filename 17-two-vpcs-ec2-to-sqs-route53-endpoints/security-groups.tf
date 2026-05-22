# this file has three security groups, one for the ec2 instance, one for ec2 
# direct connect endpoint, and one for vpc interface endpoint


#########################################################################
##################### EC2 SECURITY GROUP & RULES ########################
#########################################################################

resource "aws_security_group" "security_group_for_ec2_instance" {
  name   = "security_group_for_ec2_instance"
  vpc_id = aws_vpc.vpc_for_ec2.id
  tags   = { Name = "security_group_for_ec2_instance" }
}

# allow SSH into the EC2 instance
resource "aws_vpc_security_group_ingress_rule" "ingress_ssh_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic coming from
  cidr_ipv4 = "0.0.0.0/0"

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "egress_from_ec2_to_sqs_rule" {
  security_group_id = aws_security_group.security_group_for_ec2_instance.id

  # where is the traffic going
  referenced_security_group_id = aws_security_group.security_group_for_sqs_interface_endpoint.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}



########################################################################
############# VPC INTERFACE ENDPOINT SECURITY GROUP & RULES ############
########################################################################

resource "aws_security_group" "security_group_for_sqs_interface_endpoint" {
  name   = "security_group_for_sqs_interface_endpoint"
  vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id
  tags   = { Name = "security_group_for_sqs_interface_endpoint" }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_from_ec2_to_sqs_rule" {
  security_group_id = aws_security_group.security_group_for_sqs_interface_endpoint.id

  # where is the traffic coming from
  referenced_security_group_id = aws_security_group.security_group_for_ec2_instance.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}


########################################################################
########## ROUTE53 INBOUND RESOLVER SECURITY GROUP & RULES #############
########################################################################

resource "aws_security_group" "security_group_for_route53_inbound_resolver" {
  name   = "security_group_for_route53_inbound_resolver"
  vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id
  tags   = { Name = "security_group_for_route53_inbound_resolver" }
}

resource "aws_vpc_security_group_ingress_rule" "udp_ingress_from_ec2_to_route53_inbound_rule" {
  security_group_id = aws_security_group.security_group_for_route53_inbound_resolver.id

  # where is the traffic coming from
  cidr_ipv4 = aws_vpc.vpc_for_ec2.cidr_block

  from_port = 53
  to_port   = 53

  ip_protocol = "udp"
}

resource "aws_vpc_security_group_ingress_rule" "tcp_ingress_from_ec2_to_route53_inbound_rule" {
  security_group_id = aws_security_group.security_group_for_route53_inbound_resolver.id

  # where is the traffic coming from
  cidr_ipv4 = aws_vpc.vpc_for_ec2.cidr_block

  from_port = 53
  to_port   = 53

  ip_protocol = "tcp"
}


########################################################################
########## ROUTE53 OUTBOUND RESOLVER SECURITY GROUP & RULES ############
########################################################################

resource "aws_security_group" "security_group_for_route53_outbound_resolver" {
  name   = "security_group_for_route53_outbound_resolver"
  vpc_id = aws_vpc.vpc_for_ec2.id
  tags   = { Name = "security_group_for_route53_outbound_resolver" }
}

resource "aws_vpc_security_group_egress_rule" "udp_egress_from_route53_outbound_to_sqs_endpoint_rule" {
  security_group_id = aws_security_group.security_group_for_route53_outbound_resolver.id

  # where is the traffic coming from
  cidr_ipv4 = aws_vpc.vpc_for_sqs_interface_endpoint.cidr_block

  from_port = 53
  to_port   = 53

  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "tcp_egress_from_route53_outbound_to_sqs_endpoint_rule" {
  security_group_id = aws_security_group.security_group_for_route53_outbound_resolver.id

  # where is the traffic coming from
  cidr_ipv4 = aws_vpc.vpc_for_sqs_interface_endpoint.cidr_block

  from_port = 53
  to_port   = 53

  ip_protocol = "tcp"
}