locals {
  # --------------------------------------
  # Common Tags
  # --------------------------------------
  common_tags = {
    # Application = var.app_name # moved to AWS provider "default_tags"
    Environment = var.environment
  }

  # ** could do this but it's not necessary
  # ** usage example: dynamodb_table_name = local.resource_names.dynamodb
  # resource_names = {
  #   dynamodb = "${var.app_name}-table"
  #   # etc...
  # }
}
