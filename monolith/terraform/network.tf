#-------------------------------------------------------------#
# vpc
#-------------------------------------------------------------#

resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-vpc"
  }
}

#-------------------------------------------------------------#
# vpc flow log
#-------------------------------------------------------------#
/*
resource "aws_flow_log" "vpc-flowlog" {
  log_destination      = aws_s3_bucket.vpc-flowlog.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-vpc-flowlog"
  }
}
*/
# ------------------------------------------------------------#
#  subnet
# ------------------------------------------------------------#

resource "aws_subnet" "public" {
  for_each = toset(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnets.public[index(local.azs, each.value)]
  availability_zone = each.value

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pub-subnet-${local.azs_suffix[index(local.azs, each.value)]}"
  }
}

resource "aws_subnet" "private" {
  for_each = toset(local.azs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnets.private[index(local.azs, each.value)]
  availability_zone = each.value

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pri-subnet-${local.azs_suffix[index(local.azs, each.value)]}"
  }
}

data "aws_subnets" "public" {
  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pub-subnet-*"
  }
}

data "aws_subnets" "private" {
  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pri-subnet-*"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)

  id = each.value
}

# ------------------------------------------------------------#
#  internet gateway
# ------------------------------------------------------------#

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-igw"
  }
}

# ------------------------------------------------------------#
#  nat gateway
# ------------------------------------------------------------#
/*
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.allocation_id
  subnet_id     = aws_subnet.public[local.azs[0]].id

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-nat-a"
  }
}
*/
# ------------------------------------------------------------#
#  route table public
# ------------------------------------------------------------#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pub-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

# ------------------------------------------------------------#
#  route table private
# ------------------------------------------------------------#

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    network_interface_id = "eni-014e9ee9a4921332e"
  }

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pri-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

# ------------------------------------------------------------#
#  security group public
# ------------------------------------------------------------#

resource "aws_security_group" "public" {
  description = "sg for ${local.PJPrefix}-${local.EnvPrefix}-pub-sg"
  name        = "${local.PJPrefix}-${local.EnvPrefix}-pub-sg"

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pub-sg"
  }

  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "public_default_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.public.id
  to_port           = "0"
  type              = "egress"
}

resource "aws_security_group_rule" "public_allow_icmp" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "-1"
  protocol          = "icmp"
  security_group_id = aws_security_group.public.id
  to_port           = "-1"
  type              = "ingress"
}

resource "aws_security_group_rule" "public_allow_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "443"
  protocol          = "tcp"
  security_group_id = aws_security_group.public.id
  to_port           = "443"
  type              = "ingress"
}

resource "aws_security_group_rule" "public_allow_http" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "80"
  protocol          = "tcp"
  security_group_id = aws_security_group.public.id
  to_port           = "80"
  type              = "ingress"
}

resource "aws_security_group_rule" "public_allow_self_ingress" {
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.public.id
  self              = "true"
  to_port           = "0"
  type              = "ingress"
}

resource "aws_security_group_rule" "public_allow_private_ingress" {
  from_port                = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.public.id
  source_security_group_id = aws_security_group.private.id
  to_port                  = "0"
  type                     = "ingress"
}

# ------------------------------------------------------------#
#  security group private
# ------------------------------------------------------------#

resource "aws_security_group" "private" {
  description = "sg for ${local.PJPrefix}-${local.EnvPrefix}-pri-sg"
  name        = "${local.PJPrefix}-${local.EnvPrefix}-pri-sg"

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-pri-sg"
  }
  
  vpc_id = aws_vpc.this.id
}

resource "aws_security_group_rule" "private_default_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  to_port           = "0"
  type              = "egress"
}

resource "aws_security_group_rule" "private_allow_self_ingress" {
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.private.id
  self              = "true"
  to_port           = "0"
  type              = "ingress"
}

resource "aws_security_group_rule" "private_allow_public_ingress" {
  from_port                = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.private.id
  source_security_group_id = aws_security_group.public.id
  to_port                  = "0"
  type                     = "ingress"
}

data "aws_security_group" "private" {
  filter {
    name   = "group-name"
    values = ["${local.PJPrefix}-${local.EnvPrefix}-pri-sg"]
  }
}

# ------------------------------------------------------------#
#  vpc endpoint
# ------------------------------------------------------------#

## -----------------------------------------------------------#
##  s3
## -----------------------------------------------------------#
/*
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    "Name" = "${local.PJPrefix}-${local.EnvPrefix}-s3"
  }
}
*/
## -----------------------------------------------------------#
##  ecr
## -----------------------------------------------------------#
/*
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${local.PJPrefix}-${local.EnvPrefix}-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${local.PJPrefix}-${local.EnvPrefix}-ecr-api"
  }
}
*/

# ------------------------------------------------------------#
#  resource gateway
# ------------------------------------------------------------#
/*
resource "aws_vpclattice_resource_gateway" "rds" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-rds-rgw"
  vpc_id              = aws_vpc.this.id
  subnet_ids          = data.aws_subnets.private.ids
  security_group_ids  = [aws_security_group.private.id]

  tags = {
    
  }
}

resource "aws_vpclattice_resource_configuration" "rds" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-rds-rc"

  resource_gateway_identifier = aws_vpclattice_resource_gateway.rds.id

  port_ranges = ["5432"]
  protocol    = "TCP"

  resource_configuration_definition {
    dns_resource {
      domain_name     = "example.com"
      ip_address_type = "IPV4"
    }
  }

  tags = {
    
  }
}
*/