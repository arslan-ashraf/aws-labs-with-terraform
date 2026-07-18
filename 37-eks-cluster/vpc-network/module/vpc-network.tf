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

resource "aws_subnet" "public_subnet_for_NAT_instance" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.NAT_instance_AZ
  cidr_block        = var.NAT_instance_cidr_block

  lifecycle {
    precondition {
      condition     = contains(data.aws_availability_zones.AZs.names, var.NAT_instance_AZ)
      error_message = "Invalid AZ provided: only allowed AZs [${join(", ", data.aws_availability_zones.AZs.names)}]."
    }
  }

  tags = { Name = "public_subnet_for_NAT_instance" }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
}

###################################################################
########################## NAT GATEWAY ############################
###################################################################


# ============================================================
# ===== WE DON'T USE THE MANAGED NAT GATEWAY IN THIS LAB =====
# ===== INSTEAD WE'LL USE A MANUAL NAT INSTANCE          =====
# ============================================================



# # allocate elastic IP (EIP) for the nat gateway
# resource "aws_eip" "nat_gateway_eip" {
#   domain     = "vpc"
#   depends_on = [aws_internet_gateway.main_internet_gateway]

#   tags = { Name = "nat_gateway_elastic_ip" }
# }

# # create a single NAT Gateway in any public subnet
# resource "aws_nat_gateway" "nat_gateway" {
#   public_subnets = keys(local.public_subnets)
#   allocation_id = aws_eip.nat_gateway_eip.id
#   subnet_id     = aws_subnet.subnets_in_main_vpc[public_subnets[0]].id

#   tags = { Name = "nat_gateway_in_public_subnet" }

#   # Explicit dependency to ensure proper ordering during creation/destruction
#   depends_on = [aws_internet_gateway.main_internet_gateway]
# }

###################################################################
############### ROUTE TABLE FOR PUBLIC SUBNETS ####################
###################################################################

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

  tags = { Name = "route_table_for_public_subnets" }
}

# note: a subnet can only be attached to a single route table
# hence, one route table, multiple possible subnets
resource "aws_route_table_association" "rtb_public_subnets_assoc" {
  # as listed at the top of file
  for_each        = local.public_subnets

  subnet_id      = aws_subnet.subnets_in_main_vpc[each.key].id
  route_table_id = aws_route_table.route_table_for_public_subnets[0].id
}

###################################################################
############### ROUTE TABLE FOR PRIVATE SUBNETS ###################
###################################################################

# route all outbound private subnet EC2 traffic to the NAT Gateway
resource "aws_route_table" "route_table_for_private_subnets" {
  vpc_id = aws_vpc.main.id

  route {
    # destination
    cidr_block = "0.0.0.0/0"

    # target to reach destintion
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }
  
  tags = { Name = "route_table_for_private_subnets" }
}

# note: a subnet can only be attached to a single route table
# hence, one route table, multiple possible subnets
resource "aws_route_table_association" "rtb_private_subnets_assoc" {
   # as listed at the top of file
  for_each        = local.private_subnets

  subnet_id      = aws_subnet.subnets_in_main_vpc[each.key].id
  route_table_id = aws_route_table.route_table_for_private_subnets.id
}