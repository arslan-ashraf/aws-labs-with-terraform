resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/manually-created-lambda"
}

# import the cloudwatch log group that AWS automatically created when 
# the lambda function was manually created
import {
  to = aws_cloudwatch_log_group.lambda_log_group
  id = "/aws/lambda/manually-created-lambda"
}