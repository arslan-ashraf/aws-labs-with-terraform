# the outputs below are defined in the module's network-module-outputs.tf file

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

output "NAT_instance_network_interface_id" {
  value       = module.vpc_network_module.NAT_instance_network_interface_id
  description = "The Network Interface ID of the NAT Instance"
}

output "NAT_instance_subnet_names" {
  value = module.vpc_network_module.NAT_instance_subnet_names
}

output "eks_cluster_security_group_id" {
  value = module.vpc_network_module.eks_cluster_security_group_id
}

output "eks_worker_nodes_security_group_id" {
  value = module.vpc_network_module.eks_worker_nodes_security_group_id
}