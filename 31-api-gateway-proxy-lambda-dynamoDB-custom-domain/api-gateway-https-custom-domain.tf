data "aws_acm_certificate" "tls_certificate" {
  domain = var.custom_domain
}

resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name              = var.custom_domain
  regional_certificate_arn = data.aws_acm_certificate.tls_certificate.arn
  security_policy          = "SecurityPolicy_TLS13_1_3_FIPS_2025_09"
  endpoint_access_mode     = "STRICT"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "custom_domain_gateway" {
  api_id      = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = aws_api_gateway_stage.production_stage.stage_name
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
  # base_path   = "api"
}

# what is base_path in aws_api_gateway_base_path_mapping?
# API Gateway has two different concepts of "path":
    # The base path mapping (configured on the custom domain)
    # The resource paths inside your API (/users, /orders, etc.)

# The base_path field determines which API receives requests based on
# the first segment (abcdomain.com) of the URL (abcdomaincom/users).

# So if custom domain is abcdomain.com, and API resources are /users
# and /orders, and base_path = "v1", then a call to

# https://abcdomain.com/v1/users 

# will strip the first whole segment https://abcdomain.com/v1 
# and internally forward /users

# the API resources are still the same, /users and /orders 

# if two different API Gateways are deployed on the same custom domain
# but different base_path such as "v1" and "v2", then a call to

# abcdomain.com/v1/users 

# will make the Gateway forward to /users in API A

# and a call to 

# abcdomain.com/v2/users

# will make the Gateway forward to /users in API B

# but if your only API is intended to be available as:

# abcdomain.com/users

# then omit base_path

# note that the caller must explicitly choose which base_path to call
# for example the backend or frontend calling the API must use:
// Version 1, frontend calling:
# fetch("https://abcdomain.com/v1/users")

// Version 2, frontend calling:
# fetch("https://abcdomain.com/v2/users")

# base_path feature is a routing mechanism, it doesn't hide the
# version from the caller, it simply makes it easy for the API Gateway
# to route requests to different APIs under the same custom domain