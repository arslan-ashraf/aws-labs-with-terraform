data "aws_acm_certificate" "tls_certificate" {
  domain = var.custom_domain
}

resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name     = var.custom_domain
  certificate_arn = aws_acm_certificate.tls_certificate.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "custom_domain_gateway" {
  api_id      = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.production_stage.stage_name
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
  # base_path   = "api"  # yields api.<custom_domain>
}