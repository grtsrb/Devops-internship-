output "pub_sg_id" {
  value = aws_security_group.public_security_group.id
}

output "priv_sg_id" {
  value = aws_security_group.private_security_group.id
}