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