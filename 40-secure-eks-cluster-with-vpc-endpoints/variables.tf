#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-west-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-west-1, eu-central-1)."
  }
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-14"
}
variable "vpc_cidr" {
  description = "The VPC CIDR block"
  default     = "10.20.20.0/24"
}
variable "subnet_cidr_public" {
  description = "CIDR blocks for the public subnets"
  default     = ["10.20.20.0/26", "10.20.20.64/26"]
  type        = list(any)
}
variable "subnet_cidr_private" {
  description = "CIDR blocks for the private subnets"
  default     = ["10.20.20.128/26", "10.20.20.192/26"]
  type        = list(any)
}
variable "github_actions_role_arn" {
  description = "The GitHub Actions Role ARN."
  sensitive   = true
  type        = string
}
variable "platform_reader_role_arn" {
  description = "The platform reader IAM role ARN for EKS access entry demo."
  type        = string
  default     = "arn:aws:iam::743794601996:role/app-14-platform-reader"
}