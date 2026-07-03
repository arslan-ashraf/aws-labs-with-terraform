resource "aws_cognito_user_pool" "ecommerce_user_pool" {
  name = "ecommerce_user_pool"

  # Allows users to use their email as their username
  username_attributes = ["email"]

  # Configure password complexity
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Auto-verify email addresses
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "user_pool_client"
  user_pool_id = aws_cognito_user_pool.ecommerce_user_pool.id

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH" # Required for the hosted UI
  ]

  # allowed_oauth_flows_user_pool_client = true
  # allowed_oauth_flows                  = ["code"]
  # allowed_oauth_scopes                 = ["openid", "email", "profile"]

  # Where Cognito redirects users after login/logout
  # callback_urls = ["http://localhost:3000/callback"]
  # logout_urls   = ["http://localhost:3000/logout"]

  generate_secret = false # Set to false for single page apps
}