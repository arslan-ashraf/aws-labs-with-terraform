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
  # authorizer_credentials = aws_iam_role.api_gateway_invoke_lambda_role.arn

  type            = "TOKEN"
  identity_source = "method.request.header.authorizationToken"

  authorizer_result_ttl_in_seconds = 0 # TTL of cached authorizer results
  
  # for a TOKEN authorizer, identity_validation_expression is a
  # regular expression that the token must match, without a match,
  # the API Gateway immediately rejects the request with 4xx
  # identity_validation_expression = "<regex_here>" 
  identity_validation_expression = "^user_[0-9]+$"
}

# define HTTP GET method for /users path
resource "aws_api_gateway_method" "GET_users" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id   = aws_api_gateway_resource.users_path.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.users_path_authorizer.id

  request_parameters = {
    "method.request.header.authorizationToken" = true
  }
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
    # the deployment may not be replaced by terraform even if any
    # of the items in the sha1(jsonencode([ ... ])) change, because
    # they have stable ids if they're only updated, to ensure redeployment:
    # terraform apply -replace=aws_api_gateway_deployment.api_snapshot
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users_path.id,
      aws_api_gateway_method.GET_users.id,
      aws_api_gateway_authorizer.users_path_authorizer.id,
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