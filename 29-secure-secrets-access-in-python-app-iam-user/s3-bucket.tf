resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-123abc456def"
  force_destroy = true
}