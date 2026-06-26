resource "aws_cloudfront_public_key" "cloudfront_public_key" {
  name        = "cloudfront_public_key"
  comment     = "Public key for securing access to S3"
  encoded_key = file("public_key_for_cloudfront.pem")
}

resource "aws_cloudfront_key_group" "cloudfront_public_key_group" {
  name    = "cloudfront_public_key_group"
  items   = [aws_cloudfront_public_key.cloudfront_public_key.id]
}