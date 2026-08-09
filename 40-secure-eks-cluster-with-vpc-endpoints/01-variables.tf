variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "eks_cluster_name" {
  type    = string
  default = "example_eks_cluster"
}

# enable access to the EKS API Server via private endpoint
# this is a more secure feature so that the EKS cluster can be
# accessed through a dedicated machine, but here we leave this 
# false to testing
variable "cluster_endpoint_private_access" {
  description = "Whether to enable private access to EKS control plane endpoint"
  type        = bool
  default     = false
}

# enable access to the EKS API Server via public endpoint, this allows
# access to the EKS cluster from anywhere as long as the user has
# the secret access keys
variable "cluster_endpoint_public_access" {
  description = "Whether to enable public access to EKS control plane endpoint"
  type        = bool
  default     = true
}

# EKS API Server is allowed to be reached from anywhere
variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# EC2 instance types for worker nodes, it must have at least 2vCPUs
# and 4GiB of RAM, as well as at least 3 ENIs and must be an instance
# that is compatible with AWS EKS AMIs, so t4g.medium doesn't work
variable "worker_node_instance_type" {
  description = "List of EC2 instance types for the node group"
  type        = string
  default     = "t3a.medium" # or t3.medium
}

# capacity type for node group (ON_DEMAND or SPOT)
variable "node_capacity_type" {
  description = "Instance capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

# root volume size (GiB) for worker nodes
variable "node_disk_size" {
  description = "Minimum 20 GiB is required disk size for AL2023_x86_64_STANDARD ami-type for worker nodes"
  type        = number
  default     = 20 #  in GiB
}

variable "kubernetes_version" {
  type    = string
  default = "1.36"
}

# we get this through manually typed arn:
# "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:my-secret*"
# variable "database_secrets_arn" {
#   type = string
# }