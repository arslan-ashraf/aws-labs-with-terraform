# 1. Define the SNS Topic that receives the alarm state change
resource "aws_sns_topic" "alarm_topic" {
  name = "cloudwatch-alarm-to-lambda-topic"
}

# 2. Configure the CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name          = "high-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm fires when EC2 CPU exceeds 80% and triggers Lambda."

  # Route the alarm action directly to the SNS Topic ARN
  alarm_actions = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    InstanceId = "i-0123456789abcdef0"
  }
}

# 3. Create the SNS Subscription to route messages to the Lambda function
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.target_lambda.arn
}

# 4. Grant SNS permission to invoke your Lambda function
# Lambda resource based policy
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_topic.arn
}

# 5. Define your target Lambda Function
resource "aws_lambda_function" "target_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "alarm-response-handler"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

# 6. Basic IAM Execution Role for Lambda (standard requirement)
data "aws_iam_policy_document" "lambda_trust_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_alarm_handler_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy_document.json
}
