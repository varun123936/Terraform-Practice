variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
}

variable "name_prefix" {
  description = "Common prefix used for infrastructure resource names."
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

variable "bastion_instance_type" {
  description = "Instance type for the bastion host."
  type        = string
}

variable "bastion_key_name" {
  description = "Existing AWS key pair name for the bastion host."
  type        = string
}

variable "bastion_name" {
  description = "Name tag for the bastion host."
  type        = string
}

variable "db_identifier" {
  description = "Identifier for the RDS instance."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "db_username" {
  description = "Master username for the database."
  type        = string
}

variable "db_password" {
  description = "Master password for the database."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for the RDS instance."
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group."
  type        = string
}

variable "backend_instance_type" {
  description = "Instance type for the backend server."
  type        = string
}

variable "backend_ami_id" {
  description = "AMI ID for the backend server."
  type        = string
}

variable "backend_key_name" {
  description = "Existing AWS key pair name for the backend server."
  type        = string
}

variable "backend_name" {
  description = "Name tag for the backend server."
  type        = string
}

variable "backend_alb_name" {
  description = "Name of the backend ALB."
  type        = string
}

variable "backend_alb_target_group_name" {
  description = "Name of the backend ALB target group."
  type        = string
}

variable "backend_alb_internal" {
  description = "Whether the backend ALB is internal."
  type        = bool
}

variable "backend_alb_listener_port" {
  description = "Listener port for the backend ALB."
  type        = number
}

variable "backend_alb_target_port" {
  description = "Target port for the backend ALB target group."
  type        = number
}

variable "backend_alb_health_check_path" {
  description = "Health check path for the backend ALB target group."
  type        = string
}
