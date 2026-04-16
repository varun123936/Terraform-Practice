variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "partition_key_name" {
  description = "Partition key attribute name."
  type        = string
}

variable "partition_key_type" {
  description = "Partition key attribute type. Valid values are S, N, or B."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.partition_key_type)
    error_message = "partition_key_type must be one of S, N, or B."
  }
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for the table."
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Protect the table from accidental deletion."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the DynamoDB table."
  type        = map(string)
  default     = {}
}
