# Internet VPC
resource "aws_vpc" "demo-main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "demo-main"
  }
}

# Subnets - public
resource "aws_subnet" "demo-public-1" {
  vpc_id                  = aws_vpc.demo-main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "demo-public-1"
  }
}

resource "aws_subnet" "demo-public-2" {
  vpc_id                  = aws_vpc.demo-main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}b"

  tags = {
    Name = "demo-public-2"
  }
}

# Subnets - private
resource "aws_subnet" "demo-private-1" {
  vpc_id                  = aws_vpc.demo-main.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "demo-private-1"
  }
}

resource "aws_subnet" "demo-private-2" {
  vpc_id                  = aws_vpc.demo-main.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}b"

  tags = {
    Name = "demo-private-2"
  }
}


# Internet GW
resource "aws_internet_gateway" "demo-gw" {
  vpc_id = aws_vpc.demo-main.id

  tags = {
    Name = "demo-main"
  }
}

# Route Tables
resource "aws_route_table" "demo-public" {
  vpc_id = aws_vpc.demo-main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-gw.id
  }

  tags = {
    Name = "demo-public"
  }
}

# route associations public
resource "aws_route_table_association" "demo-public-1-a" {
  subnet_id      = aws_subnet.demo-public-1.id
  route_table_id = aws_route_table.demo-public.id
}

resource "aws_route_table_association" "demo-public-2-a" {
  subnet_id      = aws_subnet.demo-public-2.id
  route_table_id = aws_route_table.demo-public.id
}
