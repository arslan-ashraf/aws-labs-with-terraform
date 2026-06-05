resource "aws_s3_bucket" "private_bucket" {
  bucket        = "my-secure-app-bucket-unique-id"
  force_destroy = true
}