module "vpc_and_subnets_module" {
  source = "./module/network"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name = "example_vpc"
  }

  subnet_config = {
    subnet_a = {
      cidr_block = "10.0.1.0/24"
      public     = true
      AZ         = "us-east-1a"
    }
    subnet_b = {
      cidr_block = "10.0.2.0/24"
      public     = false
      AZ         = "us-east-1b"
    }
    subnet_c = {
      cidr_block = "10.0.3.0/24"
      public     = true
      AZ         = "us-east-1c"
    }
  }
}