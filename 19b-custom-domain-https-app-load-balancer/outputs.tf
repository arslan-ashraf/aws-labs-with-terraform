output "acm_tls_certificate" {
  value = data.aws_acm_certificate.acm_tls_certificate.arn
}

output "arslanashraf_dot_site" {
  value = data.aws_route53_zone.arslanashraf_dot_site
}