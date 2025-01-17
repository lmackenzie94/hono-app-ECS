# Storage module variables

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}
