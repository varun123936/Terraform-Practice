output "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  value       = aws_db_subnet_group.private.name
}

output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.private.id
}

output "db_endpoint" {
  description = "Endpoint of the private RDS instance."
  value       = aws_db_instance.private.endpoint
}
