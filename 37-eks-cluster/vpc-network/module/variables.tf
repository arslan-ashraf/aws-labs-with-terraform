variable "vpc_config" {
  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The VPC cidr_block must be valid."
  }
}

variable "subnet_config" {
  type = map(object({
    AZ         = string
    cidr_block = string
    public     = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The subnet cidr_block must be valid."
  }

  # validation {
  #   condition = (
  #     length([
  #       for subnet in values(var.subnet_config) : subnet
  #       if subnet.public
  #     ]) > 0
  #     &&
  #     length([
  #       for subnet in values(var.subnet_config) : subnet
  #       if !subnet.public
  #     ]) > 0
  #   )

  #   error_message = "Must specify at least one public subnet and at least one private subnet."
  # }
}

variable "NAT_instance_subnet_config" {
  type = object({
    AZ         = string
    cidr_block = string
  })

  validation {
    condition     = can(cidrnetmask(var.NAT_instance_subnet_config.cidr_block))
    error_message = "The NAT instance subnet cidr_block must be valid."
  }
}

variable "NAT_instance_config" {
  type = object({
    AZ            = string
    instance_type = string
  })
}