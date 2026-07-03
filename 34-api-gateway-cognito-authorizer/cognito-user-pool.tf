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

# who exactly are the "clients"?
# examples of "clients" or "application clients":

# Single Page Applications (SPAs): Your React, Angular, or Vue.js frontend
# running directly in a user's web browser

# Mobile Apps: Your native iOS or Android application installed on a 
# user's phone

# Backend Servers: A Node.js, Python, or Java API that needs to verify
# users or server-to-server communication

# Smart Devices: IoT hardware or TV applications that require user login

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "backend_app_client" # client name
  user_pool_id = aws_cognito_user_pool.user_pool_database.id

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH" # Required for the hosted UI
  ]

  generate_secret = false # Set to false for single page apps

  # OAuth 2.0 settings
  # allowed_oauth_flows_user_pool_client = true
  # allowed_oauth_flows                  = ["code", "implicit", "client_credentials"]
  # allowed_oauth_scopes                 = ["email", "openid", "profile"]

  # Where Cognito redirects users after login/logout
  # callback_urls = ["http://localhost:3000/login_redirect_page"]
  # logout_urls   = ["http://localhost:3000/logout_redirect_page"]
}