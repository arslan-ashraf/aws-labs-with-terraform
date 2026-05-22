# routes queries into the VPC (INBOUND) that has the SQS interface endpoint
resource "aws_route53_resolver_endpoint" "route53_inbound_resolver_endpoint" {
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.security_group_for_route53_inbound_resolver.id
  ]

  # ip_address {} is the IP address space of the subnet where this route53 
  # inbound resolver endpoint is to be created
  ip_address {
    subnet_id = aws_subnet.private_subnet_for_sqs_interface_endpoint.id
  }

  # required for high availability
  ip_address {
    subnet_id = aws_subnet.dummy_subnet_for_sqs_interface_endpoint.id
  }

  name = "route53_inbound_resolver_endpoint"
  tags = { Name = "route53_inbound_resolver_endpoint" }
}



# routes queries out of the VPC (OUTBOUND) that which has the EC2 instance
resource "aws_route53_resolver_endpoint" "route53_outbound_resolver_endpoint" {
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.security_group_for_route53_outbound_resolver.id
  ]

  # ip_address {} is the IP address space of the subnet where this route53 
  # outbound resolver endpoint is to be created
  ip_address {
    subnet_id = aws_subnet.public_subnet_for_ec2_instance.id
  }

  # required for high availability
  ip_address {
    subnet_id = aws_subnet.dummy_subnet_in_vpc_for_ec2.id
  }

  name = "route53_outbound_resolver_endpoint"
  tags = { Name = "route53_outbound_resolver_endpoint" }
}

resource "aws_route53_resolver_rule" "outbound_to_inbound_route53_resolver_rule" {
  domain_name = "sqs.us-east-1.amazonaws.com"
  rule_type = "FORWARD"
  
}