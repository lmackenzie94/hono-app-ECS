# DATA SOURCES
# see the AWS provider documentation for all available "data sources"

# retrieves the current AWS region (as specified in the providers.tf file)
data "aws_region" "current" {}

# retrieves a list of available AWS availability zones for the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# ECR + DynamoDB
module "storage" {
  source = "./modules/storage"

  dynamodb_table_name = "${var.app_name}-table"
  ecr_repository_name = var.app_name
  common_tags         = local.common_tags
}