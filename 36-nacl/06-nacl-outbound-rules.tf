# allow outbound traffic on ephemeral ports, this is for
# return traffic for client requests
resource "aws_network_acl_rule" "allow_ephemeral_outbound" {
  network_acl_id = aws_network_acl.nacl_for_public_subnet.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}