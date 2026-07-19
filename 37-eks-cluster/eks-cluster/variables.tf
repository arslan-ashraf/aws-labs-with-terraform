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

# EC2 instance types for worker nodes
variable "node_instance_types" {
  description = "List of EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.nano"] # or t3.micro
}

# capacity type for node group (ON_DEMAND or SPOT)
variable "node_capacity_type" {
  description = "Instance capacity type: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

# root volume size (GiB) for worker nodes
variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 5
}

variable "kubernetes_version" {
  type = string
  default = "1.36"
}