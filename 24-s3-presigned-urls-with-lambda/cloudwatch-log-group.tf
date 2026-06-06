resource "aws_cloudwatch_log_group" "lambda_log_group" {

  # the name here is custom and requires a logging_config { ... } block in
  # the lambda resource, otherwise the name must be:
  # "/aws/lambda/${aws_lambda_function.presigned_url_generator_lambda.function_name}"
  # name              = "/aws/lambda/${aws_lambda_function.presigned_url_generator_lambda.function_name}"
  
  name              = "lambda_log_group"
  retention_in_days = 14

}