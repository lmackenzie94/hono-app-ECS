# --------------------------------------
# Terraform configuration for ECS
# Defines the required providers and their versions.
# By default, Terraform installs providers from the [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest).
# --------------------------------------

terraform {
  required_version = ">= 1.0.0" # ensures that the Terraform "core" version is at least 1.0.0

  # HCP Terraform (CLI-based workflow) configuration
  cloud {
    organization = "lukes-org"
    workspaces {
      name = "hono-app-ecs"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}