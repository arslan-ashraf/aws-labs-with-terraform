output "acm_tls_certificate" {
  value = data.aws_acm_certificate.acm_tls_certificate.arn
}

output "custom_domain" {
  value = data.aws_route53_zone.custom_domain
}