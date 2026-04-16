output "orders_table_name" {
  description = "Name of the orders DynamoDB table."
  value       = module.dynamodb_orders.table_name
}

output "orders_table_arn" {
  description = "ARN of the orders DynamoDB table."
  value       = module.dynamodb_orders.table_arn
}

output "orders_queue_name" {
  description = "Name of the orders SQS queue."
  value       = module.sqs_orders.queue_name
}

output "orders_queue_arn" {
  description = "ARN of the orders SQS queue."
  value       = module.sqs_orders.queue_arn
}

output "orders_queue_url" {
  description = "URL of the orders SQS queue."
  value       = module.sqs_orders.queue_url
}

output "order_receiver_function_name" {
  description = "Name of the order receiver Lambda function."
  value       = module.lambda_order_receiver.function_name
}

output "order_receiver_function_arn" {
  description = "ARN of the order receiver Lambda function."
  value       = module.lambda_order_receiver.function_arn
}

output "order_receiver_invoke_arn" {
  description = "Invoke ARN of the order receiver Lambda function."
  value       = module.lambda_order_receiver.invoke_arn
}

output "order_processor_function_name" {
  description = "Name of the order processor Lambda function."
  value       = module.lambda_order_processor.function_name
}

output "order_processor_function_arn" {
  description = "ARN of the order processor Lambda function."
  value       = module.lambda_order_processor.function_arn
}

output "order_processor_invoke_arn" {
  description = "Invoke ARN of the order processor Lambda function."
  value       = module.lambda_order_processor.invoke_arn
}

output "order_api_id" {
  description = "ID of the order API Gateway REST API."
  value       = module.api_gateway_order_api.rest_api_id
}

output "order_api_invoke_url" {
  description = "Invoke URL for the POST /order endpoint."
  value       = module.api_gateway_order_api.invoke_url
}
