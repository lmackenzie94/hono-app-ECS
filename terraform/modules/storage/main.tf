# STORAGE MODULE
# - ECR
# - DynamoDB

# --------------------------------------
# Amazon Elastic Container Registry (ECR) configuration
# Sets up the container registry where Docker images for the application will be stored.
# This registry is used by ECS to pull the container images for deployment.
# --------------------------------------
resource "aws_ecr_repository" "app" {
  name = var.ecr_repository_name

  # scans for common vulnerabilities and exposures
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(var.common_tags, {
    Name        = "${var.ecr_repository_name}-ecr"
  })
}

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
    Name        = var.dynamodb_table_name
  })
}

