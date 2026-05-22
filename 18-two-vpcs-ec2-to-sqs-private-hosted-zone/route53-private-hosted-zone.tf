# 2. Create the Private Hosted Zone and associate it with the Target VPC first
resource "aws_route53_zone" "sqs_private_hosted_zone" {
  name = "amazonaws.com"

  # The zone must be attached to at least one VPC during creation
  vpc {
    vpc_id = aws_vpc.vpc_for_sqs_interface_endpoint.id
  }
}

output "sqs_interface_endpoint" {
  value = aws_vpc_endpoint.sqs_interface_endpoint.dns_entry
}

# 3. Create an Alias Record pointing to the SQS Interface Endpoint
resource "aws_route53_record" "sqs_alias_dns_record" {
  zone_id = aws_route53_zone.sqs_private_hosted_zone.zone_id
  name    = "sqs.us-east-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.sqs_interface_endpoint.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.sqs_interface_endpoint.dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# 4. Cross-Associate the Private Hosted Zone to VPC A
resource "aws_route53_zone_association" "vpc_for_ec2_association" {
  zone_id = aws_route53_zone.sqs_private_hosted_zone.zone_id
  vpc_id  = aws_vpc.vpc_for_ec2.id
}
