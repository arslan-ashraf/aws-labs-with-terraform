output "sqs_interface_endpoint" {
  value = aws_vpc_endpoint.sqs_interface_endpoint.dns_entry
}