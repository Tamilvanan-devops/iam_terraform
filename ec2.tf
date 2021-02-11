terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.27.0"
    }
  }
}

provider "aws" {
  region= "eu-west-2"
}
resource "aws_vpc" "local" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.local.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "pubsub"
  }
}
resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.local.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pvtsub"
  }
}
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.local.id

  tags = {
    Name = "IGW"
  }
}
resource "aws_route_table" "publicrouting" {
  vpc_id = aws_vpc.local.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "pub_route"
  }
}
resource "aws_route_table_association" "public_assoication" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.publicrouting.id
}
resource "aws_eip" "elastic" {
vpc      = true
}
resource "aws_nat_gateway" "nategate" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.publicsubnet.id
}
resource "aws_route_table" "privaterouting" {
  vpc_id = aws_vpc.local.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nategate.id
  }
  tags = {
    Name = "pvt_route"
  }
}
resource "aws_route_table_association" "private_assoication" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.privaterouting.id
}
resource "aws_security_group" "public_security" {
  name        = "public_security"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.local.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_secure"
  }
}
resource "aws_instance" "public" {

  ami                         = "ami-098828924dc89ea4a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publicsubnet.id
  key_name                    =  "tamilaws1"
  vpc_security_group_ids      = [aws_security_group.public_security.id]
  associate_public_ip_address = true
}
