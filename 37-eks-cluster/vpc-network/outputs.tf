# the outputs below are defined in the module's outputs.tf file

output "vpc_id" {
  value = module.vpc_and_subnets_module.vpc_id
}

output "public_subnets_from_module" {
  value = module.vpc_and_subnets_module.public_subnets
}

output "private_subnets_from_module" {
  value = module.vpc_and_subnets_module.private_subnets
}