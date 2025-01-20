# This file defines the outputs for the storage module
# i.e. what values the module can expose/return to its parent module.
# Think of it like the module's API.

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.app_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.app_table.arn
}

  