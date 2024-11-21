
output "vpc_id" {
  value = aws_vpc.vpc_python.id
}

output "igw_id" {
  value = aws_internet_gateway.internet_gw.id
}

output "pub_rt_id" {
  value = aws_route_table.public_route_table.id
}

output "priv_rt_id" { 
  value = aws_route_table.private_route_table.id
}