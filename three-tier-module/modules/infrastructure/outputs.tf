output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.dev.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.dev.id
}
