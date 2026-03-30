variable "name_prefix" {
  description = "Common prefix used for frontend ASG resources."
  type        = string
}

variable "frontend_launch_template_id" {
  description = "Launch template ID for frontend."
  type        = string
}

variable "subnet_ids" {
  description = "Frontend subnet IDs used by the ASG."
  type        = list(string)
}

variable "frontend_target_group_arn" {
  description = "Frontend ALB target group ARN."
  type        = string
}

variable "frontend_desired_capacity" {
  description = "Desired capacity for the frontend ASG."
  type        = number
}

variable "frontend_min_size" {
  description = "Minimum size for the frontend ASG."
  type        = number
}

variable "frontend_max_size" {
  description = "Maximum size for the frontend ASG."
  type        = number
}

variable "scale_out_target_value" {
  description = "Target CPU utilization percentage for scaling."
  type        = number
}
