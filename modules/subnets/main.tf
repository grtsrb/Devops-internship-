
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_list)
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet_list[count.index].cidr_block
  availability_zone = var.public_subnet_list[count.index].availability_zone

  tags = {
    "Name" = "pub-subnet-${count.index + 1}-${var.public_subnet_list[count.index].availability_zone}-${var.env}-${var.project}"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  count          = length(var.public_subnet_list)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = var.pub_rt_id 
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_list)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_list[count.index].cidr_block
  availability_zone = var.private_subnet_list[count.index].availability_zone

  tags = {
    "Name" = "priv-subnet-${count.index + 1}-${var.private_subnet_list[count.index].availability_zone}-${var.env}-${var.project}"
  }
}

resource "aws_route_table_association" "private-subnet-route-table-association" {
  count          = length(var.private_subnet_list)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = var.priv_rt_id 
}
