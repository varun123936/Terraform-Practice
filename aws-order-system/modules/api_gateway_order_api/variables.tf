variable "api_name" {
  description = "Name of the REST API."
  type        = string
}

variable "endpoint_type" {
  description = "API Gateway endpoint type."
  type        = string
  default     = "REGIONAL"
}

variable "resource_path_part" {
  description = "Path part for the API resource."
  type        = string
  default     = "order"
}

variable "stage_name" {
  description = "Deployment stage name."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name integrated with API Gateway."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN used by API Gateway integration."
  type        = string
}

variable "tags" {
  description = "Tags to apply to API Gateway resources."
  type        = map(string)
  default     = {}
}
