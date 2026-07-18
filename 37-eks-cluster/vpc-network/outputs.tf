# the outputs below are defined in the module's outputs.tf file

output "vpc_id" {
  value = module.vpc_network_module.vpc_id
}

output "public_subnet_ids" {
  value       = module.vpc_network_module.public_subnet_ids
  description = "Public subnets for ALB, NLB, etc."
}


output "private_subnet_ids" {
  value       = module.vpc_network_module.private_subnet_ids
  description = "Private subnets for EKS worker nodes"
}