variable "aws_region" {
  description = "AWS region for the order system resources."
  type        = string
}

variable "orders_table_name" {
  description = "DynamoDB table name for storing orders."
  type        = string
}

variable "orders_table_partition_key" {
  description = "Partition key for the orders DynamoDB table."
  type        = string
}

variable "orders_table_partition_key_type" {
  description = "DynamoDB type for the orders partition key."
  type        = string
}

variable "orders_table_point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for the orders table."
  type        = bool
}

variable "orders_table_deletion_protection_enabled" {
  description = "Enable deletion protection for the orders table."
  type        = bool
}

variable "orders_queue_name" {
  description = "Name of the SQS queue for incoming orders."
  type        = string
}

variable "orders_queue_visibility_timeout_seconds" {
  description = "Visibility timeout for the SQS order queue."
  type        = number
}

variable "orders_queue_message_retention_seconds" {
  description = "Message retention period for the SQS order queue."
  type        = number
}

variable "orders_queue_sqs_managed_sse_enabled" {
  description = "Enable SQS-managed SSE for the order queue."
  type        = bool
}

variable "order_receiver_function_name" {
  description = "Lambda function name for the order receiver."
  type        = string
}

variable "order_receiver_runtime" {
  description = "Runtime for the order receiver Lambda."
  type        = string
}

variable "order_receiver_architecture" {
  description = "Architecture for the order receiver Lambda."
  type        = string
}

variable "order_receiver_handler" {
  description = "Handler for the order receiver Lambda."
  type        = string
}

variable "order_receiver_timeout" {
  description = "Timeout in seconds for the order receiver Lambda."
  type        = number
}

variable "order_receiver_memory_size" {
  description = "Memory size in MB for the order receiver Lambda."
  type        = number
}

variable "order_receiver_package_file" {
  description = "Path to the deployment package zip for the order receiver Lambda."
  type        = string
}

variable "order_receiver_environment_variables" {
  description = "Additional environment variables for the order receiver Lambda."
  type        = map(string)
}

variable "order_processor_function_name" {
  description = "Lambda function name for the order processor."
  type        = string
}

variable "order_processor_runtime" {
  description = "Runtime for the order processor Lambda."
  type        = string
}

variable "order_processor_architecture" {
  description = "Architecture for the order processor Lambda."
  type        = string
}

variable "order_processor_handler" {
  description = "Handler for the order processor Lambda."
  type        = string
}

variable "order_processor_timeout" {
  description = "Timeout in seconds for the order processor Lambda."
  type        = number
}

variable "order_processor_memory_size" {
  description = "Memory size in MB for the order processor Lambda."
  type        = number
}

variable "order_processor_package_file" {
  description = "Path to the deployment package zip for the order processor Lambda."
  type        = string
}

variable "order_processor_batch_size" {
  description = "SQS batch size for invoking the order processor Lambda."
  type        = number
}

variable "order_processor_environment_variables" {
  description = "Additional environment variables for the order processor Lambda."
  type        = map(string)
}

variable "order_api_name" {
  description = "Name of the order REST API."
  type        = string
}

variable "order_api_endpoint_type" {
  description = "Endpoint type for the order REST API."
  type        = string
}

variable "order_api_resource_path_part" {
  description = "Path part for the order API resource."
  type        = string
}

variable "order_api_stage_name" {
  description = "Stage name for the deployed order API."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
}
