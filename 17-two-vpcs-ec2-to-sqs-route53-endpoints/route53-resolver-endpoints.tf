# routes queries into the VPC (INBOUND) that has the SQS interface endpoint
# this resolver is created inside the VPC with the SQS interface endpoint
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
    subnet_id = aws_subnet.dummy_subnet_in_vpc_for_sqs_interface_endpoint.id
  }

  name = "route53_inbound_resolver_endpoint"
  tags = { Name = "route53_inbound_resolver_endpoint" }
}



# routes queries out of the VPC (OUTBOUND) that which has the EC2 instance
# this resolver is created inside the VPC with the EC2 instance
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

# this rule applies when EC2 instance makes a request to SQS using the queue url
# aws sqs send-message \
# --queue-url https://sqs.us-east-1.amazonaws.com/<aws_account_id>/simple_queue \
# --message-body "test message 1"
# this rule sends the request to the Route53 outbound resolver
resource "aws_route53_resolver_rule" "outbound_to_inbound_route53_resolver_rule" {
  domain_name          = "sqs.us-east-1.amazonaws.com"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.route53_outbound_resolver_endpoint.id
  name                 = "forward_SQS_queries_to_inbound_route53_resolver"

  # the IP address where queries for SQS should be forwarded, here the
  # target_ip { ip = <ip_address_of_route53_inbound_resolver> }
  target_ip {
    ip = [
      for ip_config in aws_route53_resolver_endpoint.route53_inbound_resolver_endpoint.ip_address : ip_config.ip
      if ip_config.subnet_id == aws_subnet.private_subnet_for_sqs_interface_endpoint.id
    ][0]
  }

}

resource "aws_route53_resolver_rule_association" "associate_route53_foward_rule_with_vpc_for_ec2" {
  resolver_rule_id = aws_route53_resolver_rule.outbound_to_inbound_route53_resolver_rule.id
  vpc_id           = aws_vpc.vpc_for_ec2.id
}