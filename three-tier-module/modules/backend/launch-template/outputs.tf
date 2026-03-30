output "backend_launch_template_id" {
  description = "ID of the backend launch template."
  value       = aws_launch_template.backend.id
}
