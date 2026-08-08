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