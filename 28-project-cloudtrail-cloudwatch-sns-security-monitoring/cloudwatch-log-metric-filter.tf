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
  name = "secret_access_count"

  # when an API calls the secret in SecretsManager, CloudTrail emits 
  # a log event that looks like this in JSON:
  # {
  #   "eventVersion": "1.08",
  #   "userIdentity": { ... },
  #   "eventTime": "2026-06-19T18:00:00Z",
  #   "eventSource": "secretsmanager.amazonaws.com",
  #   "eventName": "GetSecretValue",
  #   "awsRegion": "us-east-1",
  #   "requestParameters": {
  #     "secretId": "<secret_arn>"
  #   }
  # }

  # the pattern field below uses a filter expression, that says, in the root 
  # given by $, look at eventName and see if it equals GetSecretValue
  # if all secret retrievals were needed, this is enough, but to count a
  # specific secret's retrieval, use:
  # ($.eventName = GetSecretValue) && ($.requestParameters.secretId = \"${aws_secretsmanager_secret.example_secret.arn}\")

  # if the log data is stored as JSON use: 
  # pattern = "{ ($.eventName = GetSecretValue) && ($.requestParameters.secretId = \"${var.my_example_secret_arn}\") }"

  # CloudTrail often stores the entire JSON event payload as a string inside 
  # the log record, so the metric filter sees text rather than JSON, to
  # perform text based search:
  pattern = "\"GetSecretValue\" \"${var.my_example_secret_arn}\""

  log_group_name = aws_cloudwatch_log_group.secrets_accessed_cloudwatch_log_group.name

  metric_transformation {
    name          = "secret_access_count"  # must match cloudwatch alarm name
    namespace     = "SecurityMetrics"      # must match cloudwatch alarm namespace
    value         = "1"
    default_value = "0"
  }
}