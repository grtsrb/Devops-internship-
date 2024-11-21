resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.priv_subnet_id 

  tags = {
    "Name" = "rds-subnet-group"
  }
}

resource "aws_db_instance" "rds-database" {
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  db_name                = var.db_name 
  engine                 = var.engine
  instance_class         = var.instance_class
  username               = var.db_username
  password               = "nikola1234"
  vpc_security_group_ids = [var.priv_sg_id]
  skip_final_snapshot    = true

  tags = {
    "Name" = "rds-${var.region}-${var.env}-${var.project}"
  }
}
