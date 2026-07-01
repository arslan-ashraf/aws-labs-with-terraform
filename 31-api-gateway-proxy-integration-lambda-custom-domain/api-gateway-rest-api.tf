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

# define HTTP GET method for /users path
resource "aws_api_gateway_method" "GET_users" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.users_path.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
}


#####################################################################
# to create root path, omit aws_api_gateway_resource completely
# only create aws_api_gateway_method and aws_api_gateway_integration
#####################################################################
# resource "aws_api_gateway_method" "GET_root" {
#   authorization = "NONE"
#   http_method   = "GET"
#   rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
#   resource_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
# }



# In aws_api_gateway_integration, what is type = "AWS_PROXY"?
# type = "AWS_PROXY" makes Lambda proxy integration turned on
# which passes the full request to Lambda, and Lambda returns 
# the full HTTP response (statusCode, headers, body)

# integrate GET /users with the Lambda function
resource "aws_api_gateway_integration" "integrate_GET_users_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id             = aws_api_gateway_resource.users_path.id
  http_method             = aws_api_gateway_method.GET_users.http_method
  type                    = "AWS_PROXY" # pass full request to Lambda
  integration_http_method = "POST"      # for Lambda, always "POST"
  uri                     = aws_lambda_function.get_user_data_dynamoDB_lambda.invoke_arn
}


# What is a aws_api_gateway_deployment for?
# API Gateway deployments are snapshots, meaning it can then be published 
# to as many callable endpoints as desired via aws_api_gateway_stage
# myapi.com/dev-stage, myapi.com/prod-stage, etc.

# optionally, the API gateway can be managed further by the following:
# aws_api_gateway_base_path_mapping
# aws_api_gateway_domain_name, 
# aws_api_method_settings

resource "aws_api_gateway_deployment" "api_snapshot" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id

  # triggers { ... } tell Terraform when to create a new deployment
  # if you change a method, integration or mapping template, Terraform 
  # doesn't automatically know it needs a new deployment, to ensure 
  # redployment of the API gateway, we use a hash function such as SHA1(),
  # when any value in the hash changes, Terraform replaces the deployment,
  # without triggers, even if the API configuration is updated, the 
  # deployed API continues operating with the old configuration

  triggers = {
    # the configuration below will satisfy ordering considerations
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