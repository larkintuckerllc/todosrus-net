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
    Name = "development"
  }
}

resource "aws_subnet" "s0" {
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.this.id
}

resource "aws_subnet" "s1" {
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.this.id
}

resource "aws_subnet" "s2" {
  availability_zone = "us-east-1c"
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "s0" {
  subnet_id      = aws_subnet.s0.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "s1" {
  subnet_id      = aws_subnet.s1.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route_table_association" "s2" {
  subnet_id      = aws_subnet.s2.id
  route_table_id = aws_route_table.this.id
}

resource "aws_network_acl" "this" {
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
