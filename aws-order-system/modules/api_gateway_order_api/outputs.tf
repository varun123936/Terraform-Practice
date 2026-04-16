output "rest_api_id" {
  description = "REST API ID."
  value       = aws_api_gateway_rest_api.this.id
}

output "execution_arn" {
  description = "Execution ARN of the REST API."
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "stage_name" {
  description = "API Gateway stage name."
  value       = aws_api_gateway_stage.this.stage_name
}

output "invoke_url" {
  description = "Invoke URL for the /order endpoint."
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}/${var.resource_path_part}"
}

data "aws_region" "current" {}
