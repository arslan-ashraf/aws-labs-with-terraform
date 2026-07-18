module "vpc_and_subnets_module" {
  source = "./module"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "EKS_WORKER_NODES_VPC"  # tag name
  }

  subnet_config = {
    # subnets a and b are private for hosting EKS worker nodes
    private_subnet_a = {
      cidr_block = "10.0.1.0/24"
      public     = false
      AZ         = "us-east-1a"
    }
    private_subnet_b = {
      cidr_block = "10.0.2.0/24"
      public     = false
      AZ         = "us-east-1b"
    }

    # NAT instance subnet is a public subnet, for hosting the NAT Instance
    # so worker nodes can pull Docker images, install Helm charts, etc.
    NAT_instance_subnet_config = {
      cidr_block = "10.0.3.0/24"
      AZ         = "us-east-1a"
    }

    
  }
}