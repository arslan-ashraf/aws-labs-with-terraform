data "aws_acm_certificate" "acm_tls_certificate" {
  domain = var.custom_domain
}