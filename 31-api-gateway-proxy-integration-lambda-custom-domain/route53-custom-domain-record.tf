resource "aws_api_gateway_domain_name" "api" {
  domain_name     = var.custom_domain
  certificate_arn = aws_acm_certificate.tls_certificate.arn
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.example.zone_id
  name    = "api"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api.cloudfront_zone_id
    evaluate_target_health = false
  }
}




data "aws_route53_zone" "custom_domain" {
  name         = var.custom_domain
  private_zone = false
}

resource "aws_route53_record" "custom_domain_record" {
  zone_id = data.aws_route53_zone.custom_domain.zone_id
  name    = var.custom_domain
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
  
}