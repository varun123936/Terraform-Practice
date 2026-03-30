variable "name_prefix" {
  description = "Common prefix used for backend ASG resources."
  type        = string
}

variable "backend_launch_template_id" {
  description = "Launch template ID for backend."
  type        = string
}

variable "subnet_ids" {
  description = "Backend subnet IDs used by the ASG."
  type        = list(string)
}

variable "backend_target_group_arn" {
  description = "Backend ALB target group ARN."
  type        = string
}

variable "backend_desired_capacity" {
  description = "Desired capacity for the backend ASG."
  type        = number
}

variable "backend_min_size" {
  description = "Minimum size for the backend ASG."
  type        = number
}

variable "backend_max_size" {
  description = "Maximum size for the backend ASG."
  type        = number
}

variable "scale_out_target_value" {
  description = "Target CPU utilization percentage for scaling."
  type        = number
}
