output "vpc_id" {
  description = "ID of the VPC."
  value       = module.infrastructure.vpc_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = module.infrastructure.internet_gateway_id
}

output "bastion_instance_id" {
  description = "ID of the bastion EC2 instance."
  value       = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion EC2 instance."
  value       = module.bastion.bastion_public_ip
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  value       = module.database.db_subnet_group_name
}

output "db_instance_id" {
  description = "RDS instance identifier."
  value       = module.database.db_instance_id
}

output "db_endpoint" {
  description = "Endpoint of the private RDS instance."
  value       = module.database.db_endpoint
}
