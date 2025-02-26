# --------------------------------------
# Terraform configuration for ECR
# Defines the required providers and their versions.
# By default, Terraform installs providers from the [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest).
# --------------------------------------

terraform {
  # ensures that the Terraform "core" version is at least 1.10 and allows for minor version updates
  # tilde (~) allows the right-most version number to increment
  required_version = "~> 1.10"

  # HCP Terraform (CLI-based workflow) configuration
  cloud {
    organization = "lukes-org"
    workspaces {
      name = "hono-app-ecr"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}