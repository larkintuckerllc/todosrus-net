terraform {
  backend "remote" {
    organization = "todosrus"
    workspaces {
      name = "todosrus-net"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Development"
  }
}

resource "aws_subnet" "s0" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Tier = "Public"
  }
  vpc_id                  = aws_vpc.this.id
}

resource "aws_subnet" "s1" {
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Tier = "Public"
  }
  vpc_id            = aws_vpc.this.id
}

resource "aws_subnet" "s2" {
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Tier = "Public"
  }
  vpc_id            = aws_vpc.this.id
}

resource "aws_subnet" "s10" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.10.0/24"
  tags = {
    Tier = "Private"
  }
  vpc_id                  = aws_vpc.this.id
}

resource "aws_subnet" "s11" {
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.11.0/24"
  tags = {
    Tier = "Private"
  }
  vpc_id            = aws_vpc.this.id
}

resource "aws_subnet" "s12" {
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.12.0/24"
  tags = {
    Tier = "Private"
  }
  vpc_id            = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_eip" "s0" {
  depends_on = [aws_internet_gateway.this]
  vpc = true
}

resource "aws_eip" "s1" {
  depends_on = [aws_internet_gateway.this]
  vpc = true
}

resource "aws_eip" "s2" {
  depends_on = [aws_internet_gateway.this]
  vpc = true
}

resource "aws_nat_gateway" "s0" {
  allocation_id = aws_eip.s0.id
  subnet_id     = aws_subnet.s0.id
}

resource "aws_nat_gateway" "s1" {
  allocation_id = aws_eip.s1.id
  subnet_id     = aws_subnet.s1.id
}

resource "aws_nat_gateway" "s2" {
  allocation_id = aws_eip.s2.id
  subnet_id     = aws_subnet.s2.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "s0" {
  subnet_id      = aws_subnet.s0.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "s1" {
  subnet_id      = aws_subnet.s1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "s2" {
  subnet_id      = aws_subnet.s2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "s10" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.s0.id
  }
}

resource "aws_route_table" "s11" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.s1.id
  }
}

resource "aws_route_table" "s12" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.s2.id
  }
}

resource "aws_route_table_association" "s10" {
  subnet_id      = aws_subnet.s10.id
  route_table_id = aws_route_table.s10.id
}

resource "aws_route_table_association" "s11" {
  subnet_id      = aws_subnet.s11.id
  route_table_id = aws_route_table.s11.id
}

resource "aws_route_table_association" "s12" {
  subnet_id      = aws_subnet.s12.id
  route_table_id = aws_route_table.s12.id
}

resource "aws_network_acl" "public" {
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  subnet_ids = [
    aws_subnet.s0.id,
    aws_subnet.s1.id,
    aws_subnet.s2.id
  ] 
  vpc_id     = aws_vpc.this.id
}

resource "aws_network_acl" "private" {
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 22
    to_port    = 22 
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "udp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 1024
    to_port    = 65535
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 0
    to_port    = 0
  }
  subnet_ids = [
    aws_subnet.s10.id,
    aws_subnet.s11.id,
    aws_subnet.s12.id
  ] 
  vpc_id     = aws_vpc.this.id
}
