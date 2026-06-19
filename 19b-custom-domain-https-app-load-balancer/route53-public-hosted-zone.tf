# ALL RESOURCES IN THIS FILE ARE UNNECESSARY AND ARE THERE FOR LEARNING 
# PURPOSES, SEE THE IMPORT { ... } AND REMOVED { ... } BLOCKS


# resource "aws_route53_zone" "route53_zone_for_custom_domain" {
#   comment           = null
#   delegation_set_id = null
#   force_destroy     = null      # null means go back to default which is false
#   name              = var.custom_domain
#   tags              = {}
#   tags_all          = {}
# }

# # import public hosted zone where the custom_domain is hosted
# import {
#   to = aws_route53_zone.route53_zone_for_custom_domain
#   id = "<hosted_zone_id>"
# }


# removed block untracks the resource from the state file
# prevents destruction of resource when "terraform destroy command" is executed
# but it requires that the resource to be untracked should be  commented out first
# removed {
#   from = aws_route53_zone.route53_zone_for_custom_domain

#   lifecycle {
#     destroy = false
#   }
# }


# resource "aws_route53_record" "tls_certified_cname" {
#   health_check_id                  = null
#   name                             = "<random_string>.<custom_domain>"
#   records                          = ["_<random_string>.<random_string>.acm-validations.aws."]
#   set_identifier                   = null
#   ttl                              = 300
#   type                             = "CNAME"
#   zone_id                          = "<zone_id>"
# }

# # import CNAME Record
# import {
#   to = aws_route53_record.tls_certified_cname
#   id = "<CNAME_random_string>.<custom_domain>_CNAME"
# }

# removed block untracks the resource from the state file
# prevents destruction of resource when "terraform destroy command" is executed
# but it requires that the resource to be untracked should be  commented out first
# removed {
#   from = aws_route53_record.tls_certified_cname

#   lifecycle {
#     destroy = false
#   }
# }