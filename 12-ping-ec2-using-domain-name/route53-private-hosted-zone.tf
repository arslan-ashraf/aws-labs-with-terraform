# create the private hosting zone in Route53 which will hold the
# DNS hostname to IP records
resource "aws_route53_zone" "route53_private_hosting_zone" {
  name = aws_vpc_dhcp_options.dhcp_options_for_example_vpc.domain_name
  vpc { vpc_id = aws_vpc.example_vpc.id }
  tags = { Name = "private_hosting_for_example_vpc" }
}

# the actual DNS record mapping hostname (name field) to IP (records field)
resource "aws_route53_record" "route53_record_for_database" {
  zone_id = aws_route53_zone.route53_private_hosting_zone.zone_id
  name = "database.${aws_vpc_dhcp_options.dhcp_options_for_example_vpc.domain_name}"
  type = "A"
  ttl = 300
  records = [aws_instance.create_instances_from_map["instance1"].private_ip]
}

# the actual DNS record mapping hostname (name field) to IP (records field)
resource "aws_route53_record" "route53_record_for_app_server" {
  zone_id = aws_route53_zone.route53_private_hosting_zone.zone_id
  name = "web.${aws_vpc_dhcp_options.dhcp_options_for_example_vpc.domain_name}"
  type = "A"
  ttl = 300
  records = [aws_instance.create_instances_from_map["instance2"].private_ip]
}

# the file, etc/resolv.conf needs to be updated in order for both EC2 instances
# to use the Route53 DNS server and the records in the private hosted zone
# to fully reflect, to do that refresh the DHCP lease cache and then reboot

# for ubuntu/debian (Netplan systems)
# sudo netplan apply

# or restart the DNS resolution daemon 
# sudo systemctl restart systemd-resolved

# sude reboot