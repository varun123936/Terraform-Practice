resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds

  # Enable managed encryption without changing the queue behavior.
  sqs_managed_sse_enabled = var.sqs_managed_sse_enabled

  tags = merge(
    var.tags,
    {
      Name      = var.queue_name
      Component = "sqs"
    }
  )
}
