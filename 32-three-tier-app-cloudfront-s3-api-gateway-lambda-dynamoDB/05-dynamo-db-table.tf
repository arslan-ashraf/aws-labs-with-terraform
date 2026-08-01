resource "aws_dynamodb_table" "users_table" {
  name         = "users_table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "user_id"   # partition key, attribute { ... } must be defined
  # sort_key = ""        # sort key,      attribute { ... } must be defined

  table_class = "STANDARD" # storage class, STANDARD or STANDARD_INFREQUENT_ACCESS

  # primary and partition key
  attribute {
    name = "user_id"
    type = "S"            # S = string, N = number, B = binary
  }

  # if a GSI on user_name was desired, define:
  # attribute {
  #   name = "user_name"
  #   type = "S"
  # }

  # global_secondary_index {
  #   name            = "user_name_index"
  #   hash_key        = "user_name"
  #   projection_type = "ALL"
  # }

  point_in_time_recovery {
    enabled = false # setting true enables continuous backups
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = null # uses default AWS-managed KMS key
  }

  tags = {
    table_name = "users_table"
  }
}