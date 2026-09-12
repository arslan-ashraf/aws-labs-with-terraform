# define the base domain name for the VPC
resource "aws_vpc_dhcp_options" "dhcp_options_for_example_vpc" {
  domain_name = "example.corp"
  domain_name_servers = ["AmazonProvidedDNS"]
  
  tags = { Name = "dhcp_options_for_example_vpc" }

  # ntp_servers = "Optional"
  # netbios_name_servers = "Optional"
  # netbios_node_type = "Optional"
}

# attach dhcp options to the VPC
resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
  vpc_id = aws_vpc.example_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options_for_example_vpc.id
}