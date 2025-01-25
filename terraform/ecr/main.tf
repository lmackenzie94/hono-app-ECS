# --------------------------------------
# Amazon Elastic Container Registry (ECR) configuration
# Sets up the container registry where Docker images for the application will be stored.
# Also sets up a lifecycle policy to keep the last 3 images.
# --------------------------------------
resource "aws_ecr_repository" "app" {
  name = var.ecr_repository_name

  # scans for common vulnerabilities and exposures
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.ecr_repository_name}-ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 3 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}