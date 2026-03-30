variable "name_prefix" {
  description = "Common prefix used for backend launch template resources."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the backend instances."
  type        = string
}

variable "instance_type" {
  description = "Instance type for the backend instances."
  type        = string
}

variable "backend_sg_id" {
  description = "Backend security group ID."
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name."
  type        = string
}

variable "instance_name" {
  description = "Name tag for backend instances launched by the ASG."
  type        = string
}
