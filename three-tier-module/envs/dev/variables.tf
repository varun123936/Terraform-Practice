variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC."
  type        = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway."
  type        = string
}
