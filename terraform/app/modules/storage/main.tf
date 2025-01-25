# --------------------------------------
# Amazon DynamoDB configuration
# Sets up the DynamoDB table used by the application for data storage.
# Defines the table structure, capacity settings, and keys.
# --------------------------------------
resource "aws_dynamodb_table" "app_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(var.common_tags, {
    Name = var.dynamodb_table_name
  })
}

