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
