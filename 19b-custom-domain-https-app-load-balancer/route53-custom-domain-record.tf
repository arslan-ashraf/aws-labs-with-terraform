data "aws_route53_zone" "arslanashraf_dot_site" {
  name         = "arslanashraf.site"
  private_zone = false
}

resource "aws_route53_record" "new_record" {
  zone_id = data.aws_route53_zone.arslanashraf_dot_site.zone_id
  name    = "arslanashraf.site"
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
  
}