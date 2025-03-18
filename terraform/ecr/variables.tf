variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  validation {
    condition     = length(var.ecr_repository_name) > 0
    error_message = "ECR repository name cannot be empty."
  }
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}