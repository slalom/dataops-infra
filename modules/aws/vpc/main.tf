data "aws_availability_zones" "myAZs" {}
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}
locals { project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1) }
locals {
  my_ip      = "${chomp(data.http.icanhazip.body)}"
  my_ip_cidr = "${chomp(data.http.icanhazip.body)}/32"
}
locals {
  admin_cidr = flatten([local.my_ip_cidr, var.admin_cidr])
}
resource "aws_eip" "myEIP" {
  tags = {
    Name    = "${var.name_prefix}EIP"
    project = local.project_shortname
  }
}
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "${var.name_prefix}VPC"
    project = local.project_shortname
  }
}

resource "aws_subnet" "myPublicSubnets" {
  count = 2

  availability_zone       = "${data.aws_availability_zones.myAZs.names[count.index]}"
  cidr_block              = "10.0.${count.index + 2}.0/24"
  vpc_id                  = "${aws_vpc.myVPC.id}"
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.name_prefix}PublicSubnet-${count.index}"
    project = local.project_shortname
  }
}

resource "aws_subnet" "myPrivateSubnets" {
  count = 2

  availability_zone = "${data.aws_availability_zones.myAZs.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.myVPC.id}"
  tags = {
    Name    = "${var.name_prefix}PrivateSubnet-${count.index}"
    project = local.project_shortname
  }
}

resource "aws_internet_gateway" "myIGW" {
  vpc_id = "${aws_vpc.myVPC.id}"
  tags = {
    Name    = "${var.name_prefix}IGW"
    project = local.project_shortname
  }
}

resource "aws_nat_gateway" "myNATGateway" {
  allocation_id = "${aws_eip.myEIP.id}"
  subnet_id     = "${aws_subnet.myPublicSubnets.0.id}"
  tags = {
    Name    = "${var.name_prefix}NAT"
    project = local.project_shortname
  }
}

resource "aws_route_table" "myPublicRT" {
  vpc_id = "${aws_vpc.myVPC.id}"
  tags = {
    Name    = "${var.name_prefix}PublicRT"
    project = local.project_shortname
  }
}

resource "aws_route_table_association" "myPublicRTAssoc" {
  count          = 2
  route_table_id = "${aws_route_table.myPublicRT.id}"
  subnet_id      = "${aws_subnet.myPublicSubnets.*.id[count.index]}"
}

resource "aws_route" "myIGWRoute" {
  route_table_id         = "${aws_route_table.myPublicRT.id}"
  gateway_id             = "${aws_internet_gateway.myIGW.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "myPrivateRT" {
  vpc_id = "${aws_vpc.myVPC.id}"
  tags = {
    Name    = "${var.name_prefix}PrivateRT"
    project = local.project_shortname
  }
}

resource "aws_route_table_association" "myPrivateRTAssoc" {
  count          = 2
  route_table_id = "${aws_route_table.myPrivateRT.id}"
  subnet_id      = "${aws_subnet.myPrivateSubnets.*.id[count.index]}"
}

resource "aws_route" "myNATRoute" {
  route_table_id         = "${aws_route_table.myPrivateRT.id}"
  nat_gateway_id         = "${aws_nat_gateway.myNATGateway.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name_prefix}SecurityGroupForECS"
  description = "allow inbound access on specified ports"
  vpc_id      = "${aws_vpc.myVPC.id}"
  tags        = { project = local.project_shortname }
  dynamic "ingress" {
    for_each = var.app_ports
    content {
      protocol    = "tcp"
      from_port   = "${ingress.value}"
      to_port     = "${ingress.value}"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}
