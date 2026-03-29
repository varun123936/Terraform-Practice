variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target group are created."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID attached to the ALB."
  type        = string
}

variable "target_instance_id" {
  description = "EC2 instance ID to register with the target group."
  type        = string
}

variable "internal" {
  description = "Whether the ALB is internal."
  type        = bool
  default     = false
}

variable "listener_port" {
  description = "Listener port for the ALB."
  type        = number
  default     = 80
}

variable "target_port" {
  description = "Target port for the registered backend."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the target group."
  type        = string
  default     = "/"
}
