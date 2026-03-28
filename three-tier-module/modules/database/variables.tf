variable "db_subnet_ids" {
  description = "Subnet IDs used by the DB subnet group."
  type        = list(string)
}

variable "database_sg_id" {
  description = "Security group ID for the private RDS instance."
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
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "subnet_group_name" {
  description = "Name of the DB subnet group."
  type        = string
  default     = "dev-db-subnet-group"
}
