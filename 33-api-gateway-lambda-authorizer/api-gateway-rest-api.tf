# REST API gateway
resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name = "example_rest_api_gateway"

  endpoint_configuration {
    types           = ["REGIONAL"] # PRIVATE or EDGE
    ip_address_type = "dualstack"  # type of IP addresses that can invoke API
  }
}

# create /users path
resource "aws_api_gateway_resource" "users_path" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_authorizer" "users_path_authorizer" {
  name           = "users_path_authorizer"
  rest_api_id    = aws_api_gateway_rest_api.rest_api_gateway.id
  authorizer_uri = aws_lambda_function.authorizer_lambda.invoke_arn

  type = "Optional"
  authorizer_credentials = "Optional"
  authorizer_result_ttl_in_seconds = "Optional"
  identity_validation_expression = "Optional"
}

# define HTTP GET method for /users path
resource "aws_api_gateway_method" "GET_users" {
  authorization = "NONE"
  http_method   = "GET"
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id   = aws_api_gateway_resource.users_path.id
}

# integrate GET /users with the Lambda function
resource "aws_api_gateway_integration" "integrate_GET_users_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id             = aws_api_gateway_resource.users_path.id
  http_method             = aws_api_gateway_method.GET_users.http_method
  type                    = "AWS_PROXY" # pass full request to Lambda
  integration_http_method = "POST"      # for Lambda, always "POST"
  uri                     = aws_lambda_function.backend_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_snapshot" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users_path.id,
      aws_api_gateway_method.GET_users.id,
      aws_api_gateway_integration.integrate_GET_users_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production_stage" {
  deployment_id = aws_api_gateway_deployment.api_snapshot.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name    = "production"
}