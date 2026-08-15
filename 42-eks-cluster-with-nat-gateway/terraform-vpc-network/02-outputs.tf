# the outputs below are defined in the module's
# -outputs.tf file
output "vpc_id" {
  value = module.vpc_network_module.vpc_id
}

output "public_subnet_ids" {
  value       = module.vpc_network_module.public_subnet_ids
  description = "IDs of public subnets for ALB, NLB, etc."
}

output "public_subnets" {
  value = module.vpc_network_module.public_subnets
  description = "Public subnets for ALB, NLB, etc."
}

output "private_subnet_ids" {
  value       = module.vpc_network_module.private_subnet_ids
  description = "IDs of private subnets for EKS worker nodes"
}

output "private_subnet" {
  value       = module.vpc_network_module.private_subnets
  description = "Private subnets for EKS worker nodes"
}