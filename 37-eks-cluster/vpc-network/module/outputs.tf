locals {
  output_public_subnets = {
    # local.public_subnets is defined in vpc-network.tf
    # key takes on strings like subnet_a, subnet_b
    for key in keys(local.public_subnets) : key => {
      subnet_id         = aws_subnet.subnets_in_main_vpc[key].id
      availability_zone = aws_subnet.subnets_in_main_vpc[key].availability_zone
    }
  }

  output_private_subnets = {
    for key in keys(local.private_subnets) : key => {
      subnet_id         = aws_subnet.subnets_in_main_vpc[key].id
      availability_zone = aws_subnet.subnets_in_main_vpc[key].availability_zone
    }
  }
}

output "vpc_id" {
  value       = aws_vpc.main_vpc.id
  description = "The ID of the VPC"
}

output "public_subnets" {
  value = local.output_public_subnets
  description = "Map of public subnets and their AZs"
}

output "public_subnet_ids" {
  value = [for subnet in local.output_public_subnets: subnet.subnet_id]
  description = "List of public subnet IDs"
}

output "private_subnets" {
  value = local.output_private_subnets
  description = "Map of private subnets and their AZs"
}

output "private_subnet_ids" {
  value = [for subnet in local.output_private_subnets: subnet.subnet_id]
  description = "List of private subnet IDs"
}