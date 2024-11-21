output "rds_instance" {
  value = aws_db_instance.rds-database
}

output "db_name" {
  value = aws_db_instance.rds-database.db_name
}

output "db_username" {
  value = aws_db_instance.rds-database.username
}

output "db_port" {
  value = aws_db_instance.rds-database.port
}

output "db_hostname" {
  value = aws_db_instance.rds-database.address
}