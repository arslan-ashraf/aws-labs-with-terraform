# REST API gateway
resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name = "example_rest_api_gateway"
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