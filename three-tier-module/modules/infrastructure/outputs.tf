output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.dev.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.dev.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
    aws_subnet.private_3.id,
    aws_subnet.private_4.id,
    aws_subnet.private_5.id,
    aws_subnet.private_6.id
  ]
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = [aws_nat_gateway.nat_1.id, aws_nat_gateway.nat_2.id]
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables."
  value       = [aws_route_table.private_1a.id, aws_route_table.private_1b.id]
}

output "bastion_sg_id" {
  description = "ID of the bastion host security group."
  value       = aws_security_group.bastion_host.id
}

output "alb_frontend_sg_id" {
  description = "ID of the frontend ALB security group."
  value       = aws_security_group.alb_frontend.id
}

output "alb_backend_sg_id" {
  description = "ID of the backend ALB security group."
  value       = aws_security_group.alb_backend.id
}

output "frontend_server_sg_id" {
  description = "ID of the frontend server security group."
  value       = aws_security_group.frontend_server.id
}

output "backend_server_sg_id" {
  description = "ID of the backend server security group."
  value       = aws_security_group.backend_server.id
}

output "database_sg_id" {
  description = "ID of the database security group."
  value       = aws_security_group.database.id
}
