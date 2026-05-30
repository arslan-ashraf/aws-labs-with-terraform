resource "aws_route53_zone" "arslanashraf_dot_site" {
  comment           = null
  delegation_set_id = null
  force_destroy     = null
  name              = "arslanashraf.site"
  tags              = {}
  tags_all          = {}
}

# import public hosted zone arslanashraf.site
import {
  to = aws_route53_zone.arslanashraf_dot_site
  id = "Z04401803CHL5IPK5D5OA" # Hosted Zone ID
}


resource "aws_route53_record" "tls_certificate_cname" {
  health_check_id                  = null
  multivalue_answer_routing_policy = false
  name                             = "_7b5eefd03761c163452e0a94792668ac.arslanashraf.site"
  records                          = ["_b66cd84cd09764d438c840759a6e3cc6.jkddzztszm.acm-validations.aws."]
  set_identifier                   = null
  ttl                              = 300
  type                             = "CNAME"
  zone_id                          = "Z04401803CHL5IPK5D5OA"
}

# import CNAME Record
import {
  to = aws_route53_record.tls_certificate_cname
  id = "Z04401803CHL5IPK5D5OA__7b5eefd03761c163452e0a94792668ac.arslanashraf.site_CNAME"
}

