resource "aws_cloudfront_distribution" "three_tier_app_cloudfront" {
  origin {
    domain_name              = aws_s3_bucket.static_files_s3_bucket.bucket_regional_domain_name
    origin_id                = "S3-Website-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_access.id
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
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Website-Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Use this for the *.cloudfront.net domain
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