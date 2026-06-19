resource "aws_cloudtrail" "secret_accessed_trail" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_bucket_resource_policy]

  name                          = "secret_accessed_trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_bucket.id
  include_global_service_events = false # prevents global services (e.g., IAM) from sending logs
  enable_logging                = true  # default

  
}