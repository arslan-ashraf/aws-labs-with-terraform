# zip compilation for the Lambda source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda_function_code.mjs"
  output_path = "lambda_function_code.zip"
}

resource "aws_lambda_function" "get_user_data_dynamoDB_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "get-user-data-from-dynamoDB-table"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function_code.handler"
  runtime          = "nodejs24.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = 128 # in megabytes
  timeout     = 5   # in seconds

}

resource "aws_lambda_permission" "api_gateway_invoke_lambda_permission" {
  statement_id  = "allow_api_gateway_to_invoke_lambda"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_data_dynamoDB_lambda.function_name
  source_arn    = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/users"
}