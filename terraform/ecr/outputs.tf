output "repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}
