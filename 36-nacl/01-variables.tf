variable "ipv4_address_to_block" {
  type    = string
  # default = "142.251.41.174" # google's IPv4
  default = "74.108.58.3"
}

variable "ipv6_address_to_block" {
  type    = string
  # default = "2607:f8b0:4006:816::200e" # google's IPv6
  default = "2001:4860:7:f01::ff"
}