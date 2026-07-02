resource "aws_cloudfront_distribution" "cloudfront_cdn" {

  aliases = [var.custom_domain]

  # s3 origin
  origin {
    domain_name              = aws_s3_bucket.static_files_s3_bucket.bucket_regional_domain_name
    origin_id                = "S3-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_access.id
  }

  # API Gateway origin
  origin {
    domain_name = "${aws_api_gateway_rest_api.rest_api_gateway.id}.execute-api.${data.aws_region.current.region}.amazonaws.com"
    origin_path = "/${aws_api_gateway_stage.production_stage.stage_name}"
    
    origin_id   = "API-Gateway-Origin"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      # origin_protocol_policy = "match-viewer" means cloudfront tries to 
      # connect to EC2 matching the same protocol the viewer/user is using
      # origin_protocol_policy = "match-viewer"

      # we use http-only as the Apache server is listening on HTTP port 80
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # free tier class
  price_class = "PriceClass_100"

  # setting web_acl_id ensures WAF is enabled, by default WAF is disabled
  # web_acl_id = ""

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http2and3" # default is http2
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]

    target_origin_id = "S3-Origin"

    forwarded_values {
      query_string = true

      headers = [
        "Authorization"
      ]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    min_ttl                = 0
    default_ttl            = 30
    max_ttl                = 30
  }

  ordered_cache_behavior {
    path_pattern     = "/users*"
    target_origin_id = "API-Gateway-Origin"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]

    cached_methods = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      headers = [
          "Authorization"
      ]

      cookies {
          forward = "all"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.tls_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      # where queries to cloudfront are allowed
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
    # geo_restriction {
    #   restriction_type = "none"
    # }
  }
}


resource "aws_cloudfront_origin_access_control" "s3_access" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data aws_region "current" {}