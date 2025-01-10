# --------------------------------------
# Amazon Elastic Container Registry (ECR) configuration
# Sets up the container registry where Docker images for the application will be stored.
# This registry is used by ECS to pull the container images for deployment.
# --------------------------------------

resource "aws_ecr_repository" "app" {
  name = var.app_name
  
  tags = {
    Name        = "${var.app_name}-ecr"
    Environment = var.environment
    Application = var.app_name
  }
}