output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance."
  value       = aws_instance.frontend.id
}

output "frontend_private_ip" {
  description = "Private IP address of the frontend EC2 instance."
  value       = aws_instance.frontend.private_ip
}
