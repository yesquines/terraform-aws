resource "aws_vpc" "vpc_web" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "vpc-web" }
}

resource "aws_internet_gateway" "igw_web" {
  vpc_id = aws_vpc.vpc_web.id
  tags   = { Name = "igw-web" }
}

resource "aws_route_table" "route_igw" {
  vpc_id = aws_vpc.vpc_web.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_web.id
  }
  tags = { Name = "route-igw" }
}

resource "aws_main_route_table_association" "association_igw" {
  vpc_id         = aws_vpc.vpc_web.id
  route_table_id = aws_route_table.route_igw.id
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc_web.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc_web.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "private-subnet-2" }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc_web.id
  map_public_ip_on_launch = true
  cidr_block              = "192.168.3.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name    = "public-subnet-1"
    Network = "public"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc_web.id
  map_public_ip_on_launch = true
  cidr_block              = "192.168.4.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name    = "public-subnet-2"
    Network = "public"
  }
}

resource "aws_eip" "eip_public" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_public.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags          = { Name = "nat-gw" }
  depends_on    = [aws_internet_gateway.igw_web]
}

resource "aws_route_table" "route_natgw" {
  vpc_id = aws_vpc.vpc_web.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "route-natgw" }
}

resource "aws_route_table_association" "association_natgw1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.route_natgw.id
}

resource "aws_route_table_association" "association_natgw2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.route_natgw.id
}

resource "aws_security_group" "fw_web" {
  name   = "fw-web"
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

  tags = { Name = "fw-web" }

}
