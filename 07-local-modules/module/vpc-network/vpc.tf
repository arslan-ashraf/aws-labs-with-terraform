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
#     AZ         = "us-east-1a"
#   }
#   subnet_b = {
#     cidr_block = "10.0.2.0/24"
#     public     = false
#     AZ         = "us-east-1b"
#   }
#   subnet_c = {
#     cidr_block = "10.0.3.0/24"
#     public     = true
#     AZ         = "us-east-1c"
#   }
# }

# then the local.public_subnets at the top will return like this:
# public_subnets = {
#   subnet_a = {
#     cidr_block = "10.0.1.0/24"
#     public     = true
#     AZ         = "us-east-1a"
#   }
#   subnet_c = {
#     cidr_block = "10.0.3.0/24"
#     public     = true
#     AZ         = "us-east-1c"
#   }
# }


data "aws_availability_zones" "AZs" {
  state = "available"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = var.vpc_config.cidr_block
  tags = { Name = var.vpc_config.name }
}

resource "aws_subnet" "example_subnets" {
  for_each = var.subnet_config
  vpc_id = aws_vpc.example_vpc.id
  availability_zone = each.value.AZ
  cidr_block = each.value.cidr_block

  tags = {
    Name = "${each.value.public}_${each.key}"
  }

  lifecycle {
    precondition {
      condition = contains(data.aws_availability_zones.available.names, each.value.AZ)
      error_message = <<-EOT
      The AZ "${each.value.AZ}" provided for the subnet "${each.key}" is invalid.

      The applied AWS region "${data.aws_availability_zones.available.id}" supports
      the following AZs [${join(", ", data.aws_availability_zones.available.names)}].
      EOT
    }
  }
}