resource "aws_cloudtrail" "example" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_bucket_resource_policy]

  name                          = "example"
  s3_bucket_name                = aws_s3_bucket.example.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
}