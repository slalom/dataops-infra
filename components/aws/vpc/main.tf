/*
* The VPC module creates a number of network services which support other key AWS functions.
*
* Included automatically when creating this module:
* * 1 VPC which contains the following:
*     * 2 private subnets (for resources which **do not** need a public IP address)
*     * 2 public subnets (for resources which do need a public IP address)
*     * 1 NAT gateway (allows private subnet resources to reach the outside world)
*     * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
*     * route tables and routes to connect all of the above
*/

data "aws_region" "current" {}
data "http" "icanhazip" { url = "http://icanhazip.com" }

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  my_ip             = chomp(data.http.icanhazip.body)
  my_ip_cidr        = "${chomp(data.http.icanhazip.body)}/32"
  aws_region        = coalesce(var.aws_region, data.aws_region.current.name)
  subnet_cidrs      = coalesce(
                        var.subnet_cidrs,
                        cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)
                      )
}

#TODO: Remove this old version after all legacy dependencies have cleared.
provider "aws" {
  alias                   = "regional" # used for region-specific AZ lookup
  version                 = "~> 2.10"
  region                  = local.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

provider "aws" {
  alias                   = "region_lookup" # used for region-specific AZ lookup
  version                 = "~> 2.10"
  region                  = local.aws_region
  shared_credentials_file = var.aws_credentials_file
  profile                 = var.aws_profile
}

data "aws_availability_zones" "az_list" {
  provider = aws.region_lookup
}

resource "aws_vpc" "my_vpc" {
  count      = var.disabled ? 0 : 1
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}VPC" }
  )
}

resource "aws_subnet" "public_subnets" {
  count                   = var.disabled ? 0 : 2
  availability_zone       = data.aws_availability_zones.az_list.names[count.index]
  cidr_block              = local.subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.my_vpc[0].id
  map_public_ip_on_launch = true
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}PublicSubnet${count.index}" }
  )
}

resource "aws_subnet" "private_subnets" {
  count                   = var.disabled ? 0 : 2
  availability_zone       = data.aws_availability_zones.az_list.names[count.index]
  cidr_block              = local.subnet_cidrs[count.index + 2]
  vpc_id                  = aws_vpc.my_vpc[0].id
  map_public_ip_on_launch = false
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}PrivateSubnet${count.index}" }
  )
}

resource "aws_internet_gateway" "my_igw" {
  count  = var.disabled ? 0 : 1
  vpc_id = aws_vpc.my_vpc[0].id
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}IGW" }
  )
}

resource "aws_eip" "nat_eip" {
  count = var.disabled ? 0 : 1
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}EIP" }
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.disabled ? 0 : 1
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}NAT" }
  )
}

resource "aws_route_table" "public_rt" {
  count  = var.disabled ? 0 : 1
  vpc_id = aws_vpc.my_vpc[0].id
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}PublicRT" }
  )
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = var.disabled ? 0 : 2
  route_table_id = aws_route_table.public_rt[0].id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_route" "igw_route" {
  count                  = var.disabled ? 0 : 1
  route_table_id         = aws_route_table.public_rt[0].id
  gateway_id             = aws_internet_gateway.my_igw[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = var.disabled ? 0 : 2
  route_table_id = aws_route_table.private_rt[0].id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_route_table" "private_rt" {
  count  = var.disabled ? 0 : 1
  vpc_id = aws_vpc.my_vpc[0].id
  tags = merge(
    var.resource_tags,
    { Name = "${var.name_prefix}PrivateRT" }
  )
}

resource "aws_route" "nat_route" {
  count                  = var.disabled ? 0 : 1
  route_table_id         = aws_route_table.private_rt[0].id
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
  destination_cidr_block = "0.0.0.0/0"
}
