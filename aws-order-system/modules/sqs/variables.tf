variable "queue_name" {
  description = "Name of the SQS queue."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "How long a received message stays invisible to other consumers."
  type        = number
}

variable "message_retention_seconds" {
  description = "How long messages are retained in the queue."
  type        = number
}

variable "sqs_managed_sse_enabled" {
  description = "Enable SQS-managed server-side encryption."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the SQS queue."
  type        = map(string)
  default     = {}
}
