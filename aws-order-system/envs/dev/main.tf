module "dynamodb_orders" {
  source = "../../modules/dynamodb"

  table_name                     = var.orders_table_name
  partition_key_name             = var.orders_table_partition_key
  partition_key_type             = var.orders_table_partition_key_type
  point_in_time_recovery_enabled = var.orders_table_point_in_time_recovery_enabled
  deletion_protection_enabled    = var.orders_table_deletion_protection_enabled
  tags                           = var.tags
}

module "sqs_orders" {
  source = "../../modules/sqs"

  queue_name                 = var.orders_queue_name
  visibility_timeout_seconds = var.orders_queue_visibility_timeout_seconds
  message_retention_seconds  = var.orders_queue_message_retention_seconds
  sqs_managed_sse_enabled    = var.orders_queue_sqs_managed_sse_enabled
  tags                       = var.tags
}

module "lambda_order_receiver" {
  source = "../../modules/lambda_order_receiver"

  function_name         = var.order_receiver_function_name
  runtime               = var.order_receiver_runtime
  architecture          = var.order_receiver_architecture
  handler               = var.order_receiver_handler
  timeout               = var.order_receiver_timeout
  memory_size           = var.order_receiver_memory_size
  package_file          = var.order_receiver_package_file
  sqs_queue_arn         = module.sqs_orders.queue_arn
  sqs_queue_url         = module.sqs_orders.queue_url
  environment_variables = var.order_receiver_environment_variables
  tags                  = var.tags
}

module "lambda_order_processor" {
  source = "../../modules/lambda_order_processor"

  function_name         = var.order_processor_function_name
  runtime               = var.order_processor_runtime
  architecture          = var.order_processor_architecture
  handler               = var.order_processor_handler
  timeout               = var.order_processor_timeout
  memory_size           = var.order_processor_memory_size
  package_file          = var.order_processor_package_file
  sqs_queue_arn         = module.sqs_orders.queue_arn
  dynamodb_table_name   = module.dynamodb_orders.table_name
  dynamodb_table_arn    = module.dynamodb_orders.table_arn
  batch_size            = var.order_processor_batch_size
  environment_variables = var.order_processor_environment_variables
  tags                  = var.tags
}

module "api_gateway_order_api" {
  source = "../../modules/api_gateway_order_api"

  api_name             = var.order_api_name
  endpoint_type        = var.order_api_endpoint_type
  resource_path_part   = var.order_api_resource_path_part
  stage_name           = var.order_api_stage_name
  lambda_function_name = module.lambda_order_receiver.function_name
  lambda_invoke_arn    = module.lambda_order_receiver.invoke_arn
  tags                 = var.tags
}
