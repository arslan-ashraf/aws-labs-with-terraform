# REST API gateway
resource "aws_api_gateway_rest_api" "this" {
  name = "example-api"
}


# # HTTP API gateway
# resource "aws_apigatewayv2_api" "example" {
#   name          = "example-http-api"
#   protocol_type = "HTTP"
# }

# # Websocket API gateway
# resource "aws_apigatewayv2_api" "example" {
#   name                       = "example-websocket-api"
#   protocol_type              = "WEBSOCKET"
#   route_selection_expression = "$request.body.action"
# }