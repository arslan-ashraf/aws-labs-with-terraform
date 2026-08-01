# In aws_api_gateway_integration, how to turn Lambda proxy integration off?

# to turn Lambda proxy integration off, use: type = "AWS"
# but that requires request/response mappings because the API Gateway 
# transforms requests before they reach Lambda and transforms Lambda's
# output before it is returned to the client, the following template:

# request mappings
# request_templates = {
#   "application/json" = <<EOF
# {
#   "userId": "$input.params('user_id')",
#   "name": "$input.params('user_color')"
# }
# EOF
# }

# takes a user's request such as GET /users?user_id=123&user_color=yellow

# and transforms it into JSON using the request_templates above as:

# {
#   "user_id": "123",
#   "user_color": "yellow"
# }

# this is what Lambda receives

# in the request_templates { ... } block, $input.params() works for:
# Query string: /users?user_id=123&sort=desc → $input.params('sort')
# Path parameter: /users/{user_id} → $input.params('user_id')
# Header: X-Request-Id → $input.params('X-Request-Id')

# response mappings
# suppose Lambda returns the following JSON:

# {
#   "id": 123,
#   "first_name": "abc",
#   "last_name": "def"
# }

# then the resources aws_api_gateway_method_response and
# aws_api_gateway_integration_response is needed as follows:
# resource "aws_api_gateway_integration_response" "ok" {
#   rest_api_id = ...
#   resource_id = ...
#   http_method = ...
#   status_code = 200

#   response_templates = {
#     "application/json" = <<EOF
# {
#   "name": "$input.path('$.first_name') $input.path('$.last_name')"
#   "user_id": "$input.path('$.id')"
# }
# EOF
#   }
# }

# the client receives:
# {
  # "name": "abc def"
  # "user_id": "123"
# }