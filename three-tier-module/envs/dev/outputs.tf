output "vpc_id" {
  description = "ID of the VPC."
  value       = module.infrastructure.vpc_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = module.infrastructure.internet_gateway_id
}
