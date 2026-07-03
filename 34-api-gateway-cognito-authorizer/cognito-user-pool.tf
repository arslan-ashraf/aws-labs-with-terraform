resource "aws_cognito_user_pool" "user_pool_database" {
  name = "user_pool_database"

  # Allows users to use their email as their username
  username_attributes = ["email"]

  # Configure password complexity
  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_uppercase = false # example only
    require_numbers   = false # example only
    require_symbols   = false # example only
  }

  # Auto-verify email addresses
  auto_verified_attributes = ["email"]
}


# what is aws_cognito_user_pool_client resource?
# it is used to create and manage the Cognito app client, this 
# acts as a bridge between your application (e.g., frontend, backend)
# and the Cognito User Pool, allowing it to authenticate users, 
# manage tokens, and perform OAuth flows

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "user_pool_client"
  user_pool_id = aws_cognito_user_pool.user_pool_database.id

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH" # Required for the hosted UI
  ]

  # OAuth 2.0 settings
  # allowed_oauth_flows_user_pool_client = true
  # allowed_oauth_flows                  = ["code", "implicit", "client_credentials"]
  # allowed_oauth_scopes                 = ["email", "openid", "profile"]

  # Where Cognito redirects users after login/logout
  # callback_urls = ["http://localhost:3000/login_redirect_page"]
  # logout_urls   = ["http://localhost:3000/logout_redirect_page"]

  generate_secret = false # Set to false for single page apps
}