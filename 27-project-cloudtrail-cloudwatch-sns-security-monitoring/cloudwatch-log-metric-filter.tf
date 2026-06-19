resource "aws_cloudwatch_log_group" "secrets_accessed_cloudwatch_log_group" {
  name              = "secrets_accessed_cloudwatch_log_group"
  retention_in_days = 14
}

# what is cloudwatch log metric filter?
# a rule that scans incoming log data for specific terms, phrases or
# numeric values and generates standard metric data

# as (unstructured) logs stream in, CloudWatch evaluates the logs using
# the "pattern" field to extract and count various metrics which can then
# be used to trigger actions, such as alarms and notifications
resource "aws_cloudwatch_log_metric_filter" "secret_access_count" {
  name           = "SecretRetrievalCount"
  
  # when an API calls the secret in SecretsManager, CloudTrail emits 
  # a log event that looks like this in JSON:
  # {
  #   "eventVersion": "1.08",
  #   "userIdentity": { ... },
  #   "eventTime": "2026-06-19T18:00:00Z",
  #   "eventSource": "://amazonaws.com",
  #   "eventName": "GetSecretValue",
  #   "awsRegion": "us-east-1",
  #   "requestElements": {
  #     "secretId": "<secret_arn>"
  #   }
  # }

  # the pattern field below uses a filter expression, that says, in the root 
  # given by $, look at eventName and see if it equals GetSecretValue
  # if all secret retrievals were needed, this is enough, but to count a specific
  # secret's retrieval, use $.requestElements.secretId = \"<secret_arn>}\"

  pattern        = "{ ($.eventName = GetSecretValue) && ($.requestElements.secretId = \"${aws_secretsmanager_secret.example_secret.arn}\") }"

  log_group_name = aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.name

  metric_transformation {
    name          = "SecretRetrievalCount"
    namespace     = "AWS/CloudTrail"
    value         = "1"
    default_value = "0"
  }
}