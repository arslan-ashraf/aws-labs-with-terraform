# Network Module

This module creates a VPC, at least one public subnet and at least one private subnet, and a NAT Instance in one of the public subnets chosed arbitrarily.

Example usage:

```
# name can be anything, here we choose my_network_module
module "vpc_network_module" {
  source = "./module"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "EKS_WORKER_NODES_VPC" # tag name
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

    # subnet c is public, it is for hosting public facing resources
    # such as Load Balancers and NAT Gateways/Instances
    public_subnet_c = {
      cidr_block             = "10.0.10.0/24"
      AZ                     = "us-east-1a"
      public                 = true
      contains_NAT_instance  = true
    }

  }

  NAT_instance_config = {
    instance_type = "t2.nano"
  }
}
```