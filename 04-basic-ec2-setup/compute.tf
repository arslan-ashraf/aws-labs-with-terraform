resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0ec10929233384c7f"
  region                      = "us-east-1"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.nano"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.public_subnet_in_example_vpc.id

  vpc_security_group_ids = [
    aws_security_group.security_group_public_traffic.id
  ]

  # root_block_device {
  #   delete_on_termination = true
  #   volume_size           = 1       # 1 gigabyte
  #   volume_type           = "gp3"   # 3rd generation disk/ssd
  # }

  lifecycle {
    create_before_destroy = true
    # ignore_changes = [tags]     # tag changes made outside of terrafrom remain
  }

  tags = merge(local.common_tags, {
    Name = "for_public_subnet_in_example_vpc"
  })

  # arn                                  = ""
  # disable_api_stop                     = ""
  # disable_api_termination              = ""
  # ebs_optimized                        = ""
  # enable_primary_ipv6                  = ""
  # get_password_data                    = false
  # host_id                              = ""
  # host_resource_group_arn              = ""
  # iam_instance_profile                 = ""
  # id                                   = ""
  # instance_initiated_shutdown_behavior = ""
  # instance_lifecycle                   = ""
  # instance_state                       = ""
  # ipv6_address_count                   = ""
  # ipv6_addresses                       = ""
  # key_name                             = ""
  # monitoring                           = ""
  # outpost_arn                          = ""
  # password_data                        = ""
  # placement_group                      = ""
  # placement_partition_number           = ""
  # primary_network_interface_id         = ""
  # private_dns                          = ""
  # private_ip                           = ""
  # public_dns                           = ""
  # public_ip                            = ""
  # secondary_private_ips                = ""
  # security_groups                      = ""
  # source_dest_check                    = true
  # spot_instance_request_id             = ""
  # tags_all                             = ""
  # tenancy                              = ""
  # user_data_base64                     = ""
  # user_data_replace_on_change          = false

  # capacity_reservation_specification {}

  # cpu_options {}

  # ebs_block_device {}

  # enclave_options {}

  # ephemeral_block_device {}

  # instance_market_options {}

  # maintenance_options {}

  # metadata_options {}

  # network_interface {}

  # private_dns_name_options {}

}

resource "aws_security_group" "security_group_public_traffic" {
  name   = "security-group-for-public-traffic"
  vpc_id = aws_vpc.example_vpc.id
  tags   = merge(local.common_tags, { Name = "sg-for-public-traffic" })

  # ingress = "Optional"    # do not use, not recommended practice
  # egress = "Optional"     # do not use, not recommended practice

  # revoke_rules_on_delete = "Optional"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_traffic_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0"

  # to allow ingress traffic on only one port, set both to 80
  # otherwise set from_port to the lowest number in a range
  # and to port to highest number in range, ex: from_port = 1025, to_port = 65545
  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ingress_https_traffic_rule" {
  security_group_id = aws_security_group.security_group_public_traffic.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"
}