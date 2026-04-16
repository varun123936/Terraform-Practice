aws_region = "us-east-1"

orders_table_name               = "orders-table"
orders_table_partition_key      = "order_id"
orders_table_partition_key_type = "S"

orders_table_point_in_time_recovery_enabled = true
orders_table_deletion_protection_enabled    = true

orders_queue_name                       = "order-queue"
orders_queue_visibility_timeout_seconds = 30
orders_queue_message_retention_seconds  = 86400
orders_queue_sqs_managed_sse_enabled    = true

order_receiver_function_name         = "order-receiver"
order_receiver_runtime               = "nodejs20.x"
order_receiver_architecture          = "x86_64"
order_receiver_handler               = "index.handler"
order_receiver_timeout               = 10
order_receiver_memory_size           = 256
order_receiver_package_file          = "../../lambda_src/order_receiver/order_receiver.zip"
order_receiver_environment_variables = {}

order_processor_function_name         = "order-processor"
order_processor_runtime               = "nodejs20.x"
order_processor_architecture          = "x86_64"
order_processor_handler               = "index.handler"
order_processor_timeout               = 30
order_processor_memory_size           = 256
order_processor_package_file          = "../../lambda_src/order_processor/order_processor.zip"
order_processor_batch_size            = 1
order_processor_environment_variables = {}

order_api_name               = "order-api"
order_api_endpoint_type      = "REGIONAL"
order_api_resource_path_part = "order"
order_api_stage_name         = "prod"

tags = {
  Project     = "aws-order-system"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
