subnet_config = {
  private_subnet = { cidr_block = "10.0.0.0/24" }
  public_subnet  = { cidr_block = "10.0.1.0/24" }
}

security_group_config = {
  public_traffic_sg   = { Name = "sg_for_public_traffic" }
  private_traffic_sg  = { Name = "sg_for_private_traffic" }
}

ec2_instance_config = {
  instance1 = {
    instance_type = "t2.nano"
    ami           = "ubuntu"
  }

  instance2 = {
    instance_type = "t2.nano"
    ami           = "debian"
    subnet_name   = "public_subnet"
  }
}