# ALL RESOURCES IN THIS FILE ARE UNNECESSARY AND ARE THERE FOR LEARNING 
# PURPOSES, SEE THE IMPORT { ... } AND REMOVED { ... } BLOCKS


# resource "aws_route53_zone" "arslanashraf_dot_site" {
#   comment           = null
#   delegation_set_id = null
#   force_destroy     = null      # null means go back to default which is false
#   name              = "arslanashraf.site"
#   tags              = {}
#   tags_all          = {}
# }

# # import public hosted zone arslanashraf.site
# import {
#   to = aws_route53_zone.arslanashraf_dot_site
#   id = "Z04401803CHL5IPK5D5OA" # Hosted Zone ID
# }


# removed block untracks the resource from the state file
# prevents destruction of resource when "terraform destroy command" is executed
# but it requires that the resource to be untracked should be  commented out first
# removed {
#   from = aws_route53_zone.arslanashraf_dot_site

#   lifecycle {
#     destroy = false
#   }
# }


# resource "aws_route53_record" "tls_certified_cname" {
#   health_check_id                  = null
#   name                             = "_7b5eefd03761c163452e0a94792668ac.arslanashraf.site"
#   records                          = ["_b66cd84cd09764d438c840759a6e3cc6.jkddzztszm.acm-validations.aws."]
#   set_identifier                   = null
#   ttl                              = 300
#   type                             = "CNAME"
#   zone_id                          = "Z04401803CHL5IPK5D5OA"
# }

# # import CNAME Record
# import {
#   to = aws_route53_record.tls_certified_cname
#   id = "Z04401803CHL5IPK5D5OA__7b5eefd03761c163452e0a94792668ac.arslanashraf.site_CNAME"
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