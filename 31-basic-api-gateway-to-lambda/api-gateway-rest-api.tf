# REST API gateway
resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name = "example_rest_api_gateway"

  endpoint_configuration {
    types = ["REGIONAL"] # PRIVATE or EDGE
    ip_address_type = "dualstack"  # type of IP addresses that can invoke API
  }
}

resource "aws_api_gateway_resource" "users_path" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "GET_users" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.users_path.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id = aws_api_gateway_resource.users_path.id
  http_method = aws_api_gateway_method.GET_users.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.get_user_data_dynamoDB_lambda.invoke_arn
  source_arn = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/users"
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.example.id,
      aws_api_gateway_method.example.id,
      aws_api_gateway_integration.example.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "example"
}


# HTTP API gateway
# resource "aws_apigatewayv2_api" "http_api_gateway" {
#   name          = "http_api_gateway"
#   protocol_type = "HTTP"
# }

# # Websocket API gateway
# resource "aws_apigatewayv2_api" "websocket_api_gateway" {
#   name                       = "websocket_api_gateway"
#   protocol_type              = "WEBSOCKET"
#   route_selection_expression = "$request.body.action"
# }