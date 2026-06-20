resource "aws_cloudtrail" "secret_accessed_trail" {
  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_bucket_resource_policy]

  name                             = "secret_accessed_trail"

  # S3 bucket related fields
  s3_bucket_name                   = aws_s3_bucket.cloudtrail_logs_bucket.id
  include_global_service_events    = false # prevents global services (e.g., IAM) from sending logs
  enable_logging                   = true  # default
  enable_log_file_validation       = true

  # accessing a secret is a management event
  include_management_events        = true # default true
  exclude_management_event_sources = [
    "kms.amazonaws.com", 
    "rdsdata.amazonaws.com"
  ]

  # CloudWatch logs related fields
  # CloudTrail requires the log stream wildcard * 
  cloud_watch_logs_group_arn       = "${aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.arn}:*"

  # by default, CloudTrail only logs management events, these are administrative
  # or management operations like CreateSecret, DeleteSecret, UpdateSecurityGroup, 
  # it does not log data events, these are use operations like GetSecretValue, 
  # PutSecretValue, RunLambda, because reading secrets happens frequently and can 
  # generate massive logs, to collect data events, use:

  # advanced_event_selector {
  #   name = "Log Secrets Manager Data Events"

  #   field_selector {
  #     field  = "eventCategory"
  #     equals = ["Data"]
  #   }

  #   field_selector {
  #     field  = "resources.type"
  #     equals = ["AWS::SecretsManager::Secret"]
  #   }
  # }
}