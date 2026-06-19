resource "aws_secretsmanager_secret" "example_secret" {
  name       = "example_secret"
  # kms_key_id = "aws/secretsmanager" # this is default
}