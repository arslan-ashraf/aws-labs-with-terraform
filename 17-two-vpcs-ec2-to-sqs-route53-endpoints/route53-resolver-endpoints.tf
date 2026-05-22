resource "aws_route53_resolver_endpoint" "route53_inbound_resolver_endpoint" {
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.security_group_for_route53_inbound_resolver.id
  ]

  ip_address {
    subnet_id = aws_subnet.private_subnet_for_sqs_interface_endpoint.id
  }

  ip_address {
    subnet_id = aws_subnet.dummy_subnet_for_sqs_interface_endpoint.id
  }

  name = "route53_inbound_resolver_endpoint"
  tags = { Name = "route53_inbound_resolver_endpoint" }
}