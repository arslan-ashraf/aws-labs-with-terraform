data "aws_acm_certificate" "tls_certificate" {
  domain = var.custom_domain
}