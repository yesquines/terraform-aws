// Provide a VPC with publics and privates subnets and a security group
resource "aws_vpc" "vpc_web" {
  cidr_block           = var.vpc_network
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  tags                 = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "igw_web" {
  vpc_id = aws_vpc.vpc_web.id
  tags   = { Name = var.igw_name }
}

resource "aws_route_table" "route_igw" {
  vpc_id = aws_vpc.vpc_web.id
  route {
    cidr_block = var.route_default_cidr
    gateway_id = aws_internet_gateway.igw_web.id
  }
  tags = { Name = var.route_igw_name }
}

resource "aws_main_route_table_association" "association_igw" {
  vpc_id         = aws_vpc.vpc_web.id
  route_table_id = aws_route_table.route_igw.id
}

resource "aws_subnet" "private_subnet" {
  for_each          = var.private_subnet
  vpc_id            = aws_vpc.vpc_web.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags              = { Name = each.key }
}

resource "aws_subnet" "public_subnet" {
  for_each                = var.public_subnet
  vpc_id                  = aws_vpc.vpc_web.id
  map_public_ip_on_launch = true
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  tags = {
    Name    = each.key
    Network = "public"
  }
}

resource "aws_eip" "eip_public" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_public.id
  subnet_id     = aws_subnet.public_subnet["public_subnet1"].id
  tags          = { Name = var.natgw_name }
  depends_on    = [aws_internet_gateway.igw_web]
}

resource "aws_route_table" "route_natgw" {
  vpc_id = aws_vpc.vpc_web.id
  route {
    cidr_block     = var.route_default_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = var.route_natgw_name }
}

resource "aws_route_table_association" "association_natgw" {
  for_each       = var.private_subnet
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.route_natgw.id
}

resource "aws_security_group" "fw_web" {
  name   = var.sg_name
  vpc_id = aws_vpc.vpc_web.id

  ingress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = var.sg_name }
}

