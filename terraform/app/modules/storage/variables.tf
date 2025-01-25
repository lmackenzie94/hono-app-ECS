# Storage module variables
# i.e. inputs for the module.
# They define what the module needs to know in order to do its job.
# Can make them optional by setting a default value.

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
}
