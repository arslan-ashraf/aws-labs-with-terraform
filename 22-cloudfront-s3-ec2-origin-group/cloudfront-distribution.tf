resource "aws_cloudfront_distribution" "s3_distribution" {
  # S3 origin
  origin {
    domain_name              = aws_s3_bucket.static_files_s3_bucket.bucket_regional_domain_name
    origin_id                = "S3-Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_access.id
  }

  # EC2 origin
  origin {
    # if the EC2 instance hasn't been created yet, then it won't have a
    # domain name and setting the domain_name to the EC2 instance like this:
    # domain_name = aws_instance.my_ec2.public_dns
    # will throw a Terraform error:
    # Error: origin.0.domain_name must not be empty
    # AWS later assigns the EC2 instance its public DNS name
    # hence, the reason for using the Elastic IP and its public dns
    domain_name = aws_eip.eip_for_cloudfront_distribution.public_dns
    origin_id   = "EC2-Origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      # origin_protocol_policy = "match-viewer" means cloudfront tries to 
      # connect to EC2 using the default browser protocol, which is HTTPS
      # origin_protocol_policy = "match-viewer"

      # we use http-only as the Apache server is listening on HTTP port 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin_group {
    origin_id = "S3-EC2-Origins-Group"
    failover_criteria {
      status_codes = [403, 404, 500, 502, 503, 504]
    }
    member { origin_id = "S3-Origin" }
    member { origin_id = "EC2-Origin" }
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
    target_origin_id = "S3-EC2-Origins-Group"

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


# ensures the S3 bucket is only accessible through CloudFront
resource "aws_cloudfront_origin_access_control" "s3_access" {
  name                              = "s3-origin-access-control-"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}