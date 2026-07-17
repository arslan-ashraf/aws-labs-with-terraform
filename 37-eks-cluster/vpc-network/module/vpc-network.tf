locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public == true
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if config.public == false
  }
}

data "aws_availability_zones" "AZs" {
  state = "available"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_config.cidr_block
  tags       = { Name = var.vpc_config.name }
}

# multiple subnets (public and private) with for_each loop
resource "aws_subnet" "subnets_in_main_vpc" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = each.value.AZ
  cidr_block        = each.value.cidr_block

  tags = {
    Name = "${each.value.public == true ? "public" : "private"}_${each.key}"
  }

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.AZs.names, each.value.AZ)
      error_message = "Invalid AZ provided: only allowed AZs [${join(", ", data.aws_availability_zones.AZs.names)}]."
    }
  }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "route_table_for_public_subnets" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # there may be 0 or 1 internet gateway if there is at least one public subnet
    # in this main there is only 1 public subnet and the internet gateway is
    # wrapped inside an array, hence: main_internet_gateway[0]
    gateway_id = aws_internet_gateway.main_internet_gateway[0].id
  }
}

# note: a subnet can only be attached to a single route table
resource "aws_route_table_association" "rtb_public_subnets_assoc" {
  for_each = local.public_subnets # as listed at the top of file

  subnet_id      = aws_subnet.subnets_in_main_vpc[each.key].id
  route_table_id = aws_route_table.route_table_for_public_subnets[0].id
}