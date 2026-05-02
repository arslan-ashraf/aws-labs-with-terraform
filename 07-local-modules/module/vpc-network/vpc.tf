locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public == true    
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if config.public == false
  }
}

# if the subnet_config defined in variables.tf looks like this:
# subnet_config = {
#   subnet_a = {
#     cidr_block = "10.0.1.0/24"
#     public     = true
#     az         = "us-east-1a"
#   }
#   subnet_b = {
#     cidr_block = "10.0.2.0/24"
#     public     = false
#     az         = "us-east-1b"
#   }
#   subnet_c = {
#     cidr_block = "10.0.3.0/24"
#     public     = true
#     az         = "us-east-1c"
#   }
# }

# then the local.public_subnets at the top will return like this:
# public_subnets = {
#   subnet_a = {
#     cidr_block = "10.0.1.0/24"
#     public     = true
#     az         = "us-east-1a"
#   }
#   subnet_c = {
#     cidr_block = "10.0.3.0/24"
#     public     = true
#     az         = "us-east-1c"
#   }
# }

