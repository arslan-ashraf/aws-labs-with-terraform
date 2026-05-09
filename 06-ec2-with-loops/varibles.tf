variable "subnet_config" {
  type = map(object({
    cidr_block = string
  }))

  # ensures all provided CIDR blocks are valid
  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "CIDR Error: At least one of the privded CIDR blocks is invalid."
  }
}


variable "ec2_instance_config" {
  type = map(object({
    instance_type = string
    ami           = string
    subnet_name   = optional(string, "private_subnet")
  }))

  validation {
    condition = alltrue([
      for config in values(var.ec2_instance_config) : contains(["t2.nano"], config.instance_type)
    ])
    error_message = "Only t2.nano instances are allowed."
  }

  validation {
    condition = alltrue([
      for config in values(var.ec2_instance_config) : contains(["ubuntu", "debian"], config.ami)
    ])
    error_message = "Only \"ubuntu\" and \"debian\" AMIs are allowed."
  }
}


# not used, for illustrative purposes only, hence default = []
variable "ec2_instance_config_list" {
  default = []
  type = list(object({
    instance_type = string
    ami           = string
    subnet_name   = optional(string, "default_subnet")
  }))

  validation {
    condition = alltrue([
      for config in var.ec2_instance_config_list : contains(["t2.nano"], config.instance_type)
    ])
    error_message = "Only t2.nano instances are allowed."
  }

  validation {
    condition = alltrue([
      for config in var.ec2_instance_config_list : contains(["ubuntu", "nginx"], config.ami)
    ])
    error_message = "Only \"ubuntu\" and \"nginx\" amis are allowed."
  }
}