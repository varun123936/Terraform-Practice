variable "name_prefix" {
  description = "Common prefix used for frontend launch template resources."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the frontend instances."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the frontend instances."
  type        = string
}

variable "frontend_sg_id" {
  description = "Frontend security group ID."
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name."
  type        = string
}

variable "instance_name" {
  description = "Name tag for frontend instances launched by the ASG."
  type        = string
}
