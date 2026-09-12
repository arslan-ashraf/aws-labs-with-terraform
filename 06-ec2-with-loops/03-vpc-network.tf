resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "example_vpc" }
}

# create multiple subnets with for_each loop
resource "aws_subnet" "subnets_in_example_vpc" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.example_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = each.value.cidr_block

  tags = { Name = "${each.key}_in_example_vpc" }
}