# ECR + DynamoDB
module "storage" {
  source = "./modules/storage"

  dynamodb_table_name = "${var.app_name}-table"
  ecr_repository_name = var.app_name
  common_tags         = local.common_tags
}