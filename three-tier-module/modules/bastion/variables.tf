variable "aws_region" {
  description = "AWS region for the bastion host."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the bastion host. Leave empty to use the latest Amazon Linux 2 AMI."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type for the bastion host."
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name for SSH."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where the bastion host will be launched."
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the bastion host."
  type        = string
}

variable "instance_name" {
  description = "Name tag for the bastion instance."
  type        = string
  default     = "dev-bastion-server"
}
