# STORAGE MODULE
# - ECR
# - DynamoDB

# --------------------------------------
# Amazon Elastic Container Registry (ECR) configuration
# Sets up the container registry where Docker images for the application will be stored.
# This registry is used by ECS to push the container images for deployment.
# Also sets up a lifecycle policy to keep the last 3 images.
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

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = var.ecr_repository_name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 3 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
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

