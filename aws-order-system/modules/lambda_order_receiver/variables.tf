variable "function_name" {
  description = "Lambda function name."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs20.x"
}

variable "architecture" {
  description = "Lambda CPU architecture."
  type        = string
  default     = "x86_64"
}

variable "handler" {
  description = "Lambda handler entry point."
  type        = string
  default     = "index.handler"
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 256
}

variable "package_file" {
  description = "Path to the built Lambda deployment package zip file."
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the target SQS queue."
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the target SQS queue."
  type        = string
}

variable "environment_variables" {
  description = "Additional Lambda environment variables."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Lambda resources."
  type        = map(string)
  default     = {}
}
