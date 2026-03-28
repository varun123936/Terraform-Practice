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

variable "availability_zone_1a" {
  description = "First availability zone."
  type        = string
}

variable "availability_zone_1b" {
  description = "Second availability zone."
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet in AZ 1."
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet in AZ 2."
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 in AZ 1."
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 in AZ 1."
  type        = string
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for private subnet 3 in AZ 1."
  type        = string
}

variable "private_subnet_4_cidr" {
  description = "CIDR block for private subnet 1 in AZ 2."
  type        = string
}

variable "private_subnet_5_cidr" {
  description = "CIDR block for private subnet 2 in AZ 2."
  type        = string
}

variable "private_subnet_6_cidr" {
  description = "CIDR block for private subnet 3 in AZ 2."
  type        = string
}
