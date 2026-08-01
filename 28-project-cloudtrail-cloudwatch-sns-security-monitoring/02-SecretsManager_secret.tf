###### DO NOT USE THIS ########
# resource "aws_secretsmanager_secret" "example_secret" {
#   name = "example_secret"
#   # kms_key_id = "aws/secretsmanager" # this is default
# }

# we don't create the secret with Terraform because it can't be deleted
# arbitrarily, there is a waiting period after deletion, that's why we
# import it instead

# import {
#   to = aws_secretsmanager_secret.my_example_secret
#   identity = {
#     "arn" = var.my_example_secret_arn
#   }
# }

# resource "aws_secretsmanager_secret" "my_example_secret" {}