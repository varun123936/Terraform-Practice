output "backend_instance_id" {
  description = "ID of the backend EC2 instance."
  value       = aws_instance.backend.id
}

output "backend_private_ip" {
  description = "Private IP address of the backend EC2 instance."
  value       = aws_instance.backend.private_ip
}
