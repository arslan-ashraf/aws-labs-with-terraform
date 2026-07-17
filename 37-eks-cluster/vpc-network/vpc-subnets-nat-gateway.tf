module "vpc_and_subnets_module" {
  source = "./module"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "EKS_WORKER_NODES_VPC"
  }

  subnet_config = {
    # subnets a and b are private for hosting EKS worker nodes
    subnet_a = {
      cidr_block = "10.0.1.0/24"
      public     = false
      AZ         = "us-east-1a"
    }
    subnet_b = {
      cidr_block = "10.0.2.0/24"
      public     = false
      AZ         = "us-east-1b"
    }

    # subnet c is for hosting the NAT Gateway so worker nodes can
    # pull Docker images, install Helm charts, etc.
    subnet_c = {
      cidr_block = "10.0.3.0/24"
      public     = true
      AZ         = "us-east-1a"
    }
  }
}