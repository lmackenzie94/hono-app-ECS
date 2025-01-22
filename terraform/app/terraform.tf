# --------------------------------------
# Terraform configuration for ECS
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
      name = "hono-app-ecs" # NOTE: can't use var.app_name here (because it's not available at this point... I think?)
    }
  }

  # Local backend configuration (optional b/c Terraform uses "local" backend by default)
  # Not needed b/c we're using HCP Terraform
  # backend "local" {
  #   path = "terraform.tfstate" # this is the default path
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}