output "frontend_asg_name" {
  description = "Name of the frontend Auto Scaling Group."
  value       = aws_autoscaling_group.frontend.name
}
