variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "cluster_name" {
  type    = string
  default = "basic-eks-cluster"
}

variable "instance_type" {
  type = string
  default = "t2.nano"
}