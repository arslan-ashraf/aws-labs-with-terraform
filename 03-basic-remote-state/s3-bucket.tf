resource "random_id" "random_bucket_suffix" {
  byte_length = 5
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-example-bucket-${random_id.random_bucket_suffix.hex}"

  # bucket_prefix = "Optional"
  # acl = "Optional"
  # policy = "Optional"
  # tags = "Optional"
  # force_destroy = "Optional"
  # website = "Optional"
  # versioning = "Optional"
  # logging = "Optional"
  # lifecycle_rule = "Optional"
  # acceleration_status = "Optional"
  # region = "Optional"
  # request_payer = "Optional"
  # replication_configuration = "Optional"
  # object_lock_configuration = "Optional"

}

output "example_bucket_name" {
  value = aws_s3_bucket.example_bucket.bucket
}