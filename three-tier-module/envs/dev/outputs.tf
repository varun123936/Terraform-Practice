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

output "backend_instance_id" {
  description = "ID of the backend EC2 instance."
  value       = module.backend.backend_instance_id
}

output "backend_private_ip" {
  description = "Private IP of the backend EC2 instance."
  value       = module.backend.backend_private_ip
}

output "backend_internal_alb_dns_name" {
  description = "DNS name of the internal backend ALB."
  value       = module.backend_internal_alb.alb_dns_name
}

output "backend_internal_alb_target_group_arn" {
  description = "Target group ARN for the internal backend ALB."
  value       = module.backend_internal_alb.target_group_arn
}

output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance."
  value       = module.frontend.frontend_instance_id
}

output "frontend_private_ip" {
  description = "Private IP of the frontend EC2 instance."
  value       = module.frontend.frontend_private_ip
}

output "frontend_alb_dns_name" {
  description = "DNS name of the frontend ALB."
  value       = module.frontend_alb.alb_dns_name
}

output "frontend_alb_target_group_arn" {
  description = "Target group ARN for the frontend ALB."
  value       = module.frontend_alb.target_group_arn
}
