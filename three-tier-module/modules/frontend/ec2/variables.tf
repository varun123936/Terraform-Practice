variable "aws_region" {
  description = "AWS region for the frontend server."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the frontend server. Leave empty to use the latest Amazon Linux 2 AMI."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type for the frontend server."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name for SSH."
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID where the frontend server will be launched."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the frontend server."
  type        = string
}

variable "instance_name" {
  description = "Name tag for the frontend instance."
  type        = string
  default     = "dev-frontend-server"
}
