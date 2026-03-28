resource "aws_db_subnet_group" "private" {
  name       = var.subnet_group_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_db_instance" "private" {
  identifier             = var.db_identifier
  allocated_storage      = var.allocated_storage
  engine                 = "mysql"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.private.name
  vpc_security_group_ids = [var.database_sg_id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = var.db_identifier
  }
}
