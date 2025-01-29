variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  validation {
    condition     = length(var.ecr_repository_name) > 0
    error_message = "ECR repository name cannot be empty."
  }
}
