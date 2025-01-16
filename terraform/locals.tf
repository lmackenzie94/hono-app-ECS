locals {
  common_tags = {
    Application = var.app_name
    Environment = var.environment
  }

  # ** could do this but it's not necessary
  # ** usage example: dynamodb_table_name = local.resource_names.dynamodb
  # resource_names = {
  #   dynamodb = "${var.app_name}-table"
  #   ecr      = "${var.app_name}"
  #   # etc...
  # }
}