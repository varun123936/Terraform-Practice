variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag for the VPC."
  type        = string
  default     = "dev-vpc"
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway."
  type        = string
  default     = "dev-igw"
}
