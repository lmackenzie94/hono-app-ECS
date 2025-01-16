# --------------------------------------
# AWS Availability Zones
# Retrieves a list of available AWS availability zones for the current region.
# --------------------------------------
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