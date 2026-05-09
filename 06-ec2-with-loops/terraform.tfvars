subnet_config = {
  private_subnet = { cidr_block = "10.0.0.0/24" }
  public_subnet  = { cidr_block = "10.0.1.0/24" }
}

ec2_instance_config_map = {
  instance1 = {
    instance_type = "t2.nano"
    ami           = "ubuntu"
    # subnet_name = "private_subnet"   # default option in variables.tf
  }

  instance2 = {
    instance_type = "t2.nano"
    ami           = "debian"
    subnet_name   = "public_subnet"
  }
}