# allow inbound HTTP traffic on port 80
resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# allow inbound HTTPS traffic on port 443
resource "aws_network_acl_rule" "allow_https_inbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "block_ipv4_inbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "${var.ipv4_address_to_block}/32"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "block_ipv6_inbound" {
  network_acl_id  = aws_network_acl.nacl_for_public_subnet.id
  rule_number     = 600
  egress          = false
  protocol        = "tcp"
  rule_action     = "deny"
  ipv6_cidr_block = "${var.ipv6_address_to_block}/128"
  from_port       = 1024
  to_port         = 65535
}