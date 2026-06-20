# grant SNS permission to invoke your Lambda function

resource "aws_lambda_function" "target_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "alarm-response-handler"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}


# Lambda resource based policy
resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "Allow Lambda execution from SNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.target_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.trigger_lambda_sns_topic.arn
}