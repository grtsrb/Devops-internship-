output "rds_instance" {
  value = aws_db_instance.rds-database
}

output "db_hostname" {
  value = aws_db_instance.rds-database.address
}
