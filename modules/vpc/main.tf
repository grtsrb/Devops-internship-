
resource "aws_vpc" "vpc_python" {
  cidr_block = var.cidr_block 
  tags = {
    "Name" = "vpc-${var.region}-${var.env}-${var.project}"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc_python.id

  tags = {
    "Name" = "igw-${var.region}-${var.env}-${var.project}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_python.id

  route {
    cidr_block = var.igw_rt
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    "Name" = "pub-rt-${var.region}-${var.env}-${var.project}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_python.id

  tags = {
    "Name" = "priv-rt-${var.region}-${var.env}-${var.project}"
  }
}