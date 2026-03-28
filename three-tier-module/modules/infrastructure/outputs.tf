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
