locals {
  public_subnets = {
    for key, config in var.subnet_config : key => config if config.public == true
  }

  private_subnets = {
    for key, config in var.subnet_config : key => config if config.public == false
  }

  public_subnets_for_NAT_instance = {
    for key, config in var.subnet_config : 
    key => config if config.public == true && 
    config.contains_NAT_instance == true
  }
}


# public_subnets = {
#   subnet_a = {
#     cidr_block = "10.0.1.0/24"
#     public     = true
#     AZ         = "us-east-1a"
#   }
#   subnet_c = {
#     cidr_block = "10.0.3.0/24"
#     public     = true
#     AZ         = "us-east-1c"
#   }
# }

data "aws_availability_zones" "AZs" {
  state = "available"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_config.cidr_block
  tags       = { Name = var.vpc_config.name }
}

resource "aws_internet_gateway" "internet_gateway_for_main_vpc" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "internet_gateway_for_main_vpc" }
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


###################################################################
############### ROUTE TABLE FOR PUBLIC SUBNETS ####################
###################################################################

resource "aws_route_table" "route_table_for_public_subnets" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    # destination
    cidr_block = "0.0.0.0/0"

    # target used to get to destination
    gateway_id = aws_internet_gateway.internet_gateway_for_main_vpc.id
  }

  tags = { Name = "route_table_for_public_subnets" }
}

# note: a subnet can only be attached to a single route table
# hence, one route table, multiple possible subnets
resource "aws_route_table_association" "rtb_public_subnets_assoc" {
  # as listed at the top of file
  for_each = local.public_subnets

  subnet_id      = aws_subnet.subnets_in_main_vpc[each.key].id
  route_table_id = aws_route_table.route_table_for_public_subnets.id
}

###################################################################
############### ROUTE TABLE FOR PRIVATE SUBNETS ###################
###################################################################

# route all outbound private subnet EC2 traffic to the NAT Gateway
resource "aws_route_table" "route_table_for_private_subnets" {
  vpc_id = aws_vpc.main_vpc.id

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
  for_each = local.private_subnets

  subnet_id      = aws_subnet.subnets_in_main_vpc[each.key].id
  route_table_id = aws_route_table.route_table_for_private_subnets.id
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
#   depends_on = [aws_internet_gateway.main_vpc_internet_gateway]

#   tags = { Name = "nat_gateway_elastic_ip" }
# }

# # create a single NAT Gateway in any public subnet
# resource "aws_nat_gateway" "nat_gateway" {
#   public_subnets = keys(local.public_subnets)
#   allocation_id = aws_eip.nat_gateway_eip.id
#   subnet_id     = aws_subnet.subnets_in_main_vpc[public_subnets[0]].id

#   tags = { Name = "nat_gateway_in_public_subnet" }

#   # Explicit dependency to ensure proper ordering during creation/destruction
#   depends_on = [aws_internet_gateway.main_vpc_internet_gateway]
# }