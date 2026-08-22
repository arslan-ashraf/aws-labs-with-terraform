# allow outbound traffic on ephemeral ports, this is for
# return traffic for client requests
resource "aws_network_acl_rule" "allow_ephemeral_outbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_http_outbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_https_outbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 600
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}