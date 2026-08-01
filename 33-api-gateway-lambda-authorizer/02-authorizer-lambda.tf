# zip compilation for the Lambda source code
data "archive_file" "authorizer_lambda_zip" {
  type        = "zip"
  source_file = "./token_based_lambda_authorizer_code.mjs"
  output_path = "token_based_lambda_authorizer_code.zip"
}

resource "aws_lambda_function" "authorizer_lambda" {
  filename         = data.archive_file.authorizer_lambda_zip.output_path
  function_name    = "authorizer_lambda"
  role             = aws_iam_role.authorizer_lambda_role.arn
  handler          = "token_based_lambda_authorizer_code.handler"
  runtime          = "nodejs24.x"
  source_code_hash = data.archive_file.authorizer_lambda_zip.output_base64sha256

  memory_size = 128 # in megabytes
  timeout     = 5   # in seconds

}

resource "aws_lambda_permission" "api_gateway_invoke_authorizer_lambda_permission" {
  statement_id  = "allow_api_gateway_to_invoke_authorizer_lambda"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_lambda.function_name
  # source_arn    = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/*/GET/users"
  source_arn    = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/authorizers/${aws_api_gateway_authorizer.users_path_authorizer.id}"
}