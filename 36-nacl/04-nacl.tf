# Create the Network ACL
resource "aws_network_acl" "acl_for_public_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  subnet_ids = [aws_subnet.public_subnet.id]

  tags = {
    Name = "main-public-nacl"
  }
}