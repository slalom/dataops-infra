data "aws_region" "current" {}
data "http" "icanhazip" { url = "http://icanhazip.com" }

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip             = chomp(data.http.icanhazip.body)
  my_ip_cidr        = "${chomp(data.http.icanhazip.body)}/32"
  admin_cidr        = flatten([local.my_ip_cidr, var.admin_cidr])
  aws_region        = var.aws_region != null ? var.aws_region : data.aws_region.current.name
}

provider "aws" {
  alias  = "regional"
  region = local.aws_region
}
data "aws_availability_zones" "az_list" {
  provider = aws.regional
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "${var.name_prefix}VPC"
    project = local.project_shortname
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.az_list.names[count.index]
  cidr_block              = "10.0.${count.index + 2}.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.name_prefix}PublicSubnet-${count.index}"
    project = local.project_shortname
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = 2
  availability_zone       = data.aws_availability_zones.az_list.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.name_prefix}PrivateSubnet-${count.index}"
    project = local.project_shortname
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name    = "${var.name_prefix}IGW"
    project = local.project_shortname
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name    = "${var.name_prefix}EIP"
    project = local.project_shortname
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    Name    = "${var.name_prefix}NAT"
    project = local.project_shortname
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name    = "${var.name_prefix}PublicRT"
    project = local.project_shortname
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.my_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = 2
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name    = "${var.name_prefix}PrivateRT"
    project = local.project_shortname
  }
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
