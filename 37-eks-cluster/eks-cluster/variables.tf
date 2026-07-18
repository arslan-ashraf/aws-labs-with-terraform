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
  type        = list(string)
  default     = ["0.0.0.0/0"]
}