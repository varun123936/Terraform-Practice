resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.partition_key_name

  deletion_protection_enabled = var.deletion_protection_enabled

  attribute {
    name = var.partition_key_name
    type = var.partition_key_type
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}
