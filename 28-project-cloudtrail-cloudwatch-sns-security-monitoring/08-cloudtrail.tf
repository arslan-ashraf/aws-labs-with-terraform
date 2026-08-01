resource "aws_cloudtrail" "secret_accessed_trail" {

  # send CloudTrail logs to CloudWatch
  # CloudTrail requires the log stream wildcard * 
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn

  name = "secret_accessed_trail"

  # send CloudTrail logs to the S3 bucket 
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs_bucket.id
  include_global_service_events = false # prevents global services (e.g., IAM) from sending logs
  enable_logging                = true  # default
  enable_log_file_validation    = true

  # this determines which events CloudTrail will record
  event_selector {
    read_write_type           = "ReadOnly" # WriteOnly, All
    include_management_events = true # default true

    exclude_management_event_sources = [
      "rdsdata.amazonaws.com",
      # "kms.amazonaws.com"
    ]

    # event_selector is older but necessary for Management Events
    # the data_resource only supports:
    # ["AWS::DynamoDB::Table", "AWS::Lambda::Function", "AWS::S3::Object"]

    # collect logs from all Lambda functions
    # data_resource {
    #   type   = "AWS::Lambda::Function"
    #   values = ["arn:aws:lambda"]
    # }
  }

  # by default, CloudTrail only logs management events, these are administrative
  # or management operations like CreateSecret, DeleteSecret, GetSecretValue, 
  # UpdateSecurityGroup, IAM changes

  # it does not log data events, these are object level events like S3 ReadObject,
  # PutSecretValue, InvokeLambda, because read and use event happens frequently 
  # and can generate massive logs, to collect data events, use:
}


# does not work for Management events
# advanced_event_selector {
#   name = "Log Data Events"

#   # target only Data Events, but accessing a secret is a management event
#   field_selector {
#     field  = "eventCategory"
#     equals = ["Data"]
#   }

#   # record read only events
#   field_selector {
#     field  = "readOnly"
#     equals = [true]
#   }

  # with management events, we can't target the specific secret's ARN
  # or the GetSecretValue event, CloudTrail's management events do not allow 
  # filtering on the eventName and resources.ARN field, but data events do
  # hence the following field_selectors do not work with management 
  # events, but they do work with data events

  # field_selector {
  #   field  = "resources.ARN"
  #   equals = [var.my_example_secret_arn]
  # }

  # target the specific eventName
  # field_selector {
  #   field  = "eventName"
  #   equals = ["GetSecretValue"]
  # }

  # target the specific AWS service
  # field_selector {
  #   field  = "resources.type"
  #   equals = ["AWS::SecretsManager::Secret"]
  # }

  # field_selector {
  #   field  = "eventSource"
  #   equals = ["kms.amazonaws.com"]
  # }

# }