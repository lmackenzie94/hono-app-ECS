# --------------------------------------
# AWS Provider configuration
# This file configures the AWS provider with the specified region and profile.
# It serves as the main connection point to AWS for all other resources.
# --------------------------------------

# Terraform configuration 
# Defines the required providers and their versions.
# By default, Terraform installs providers from the [Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest).
terraform {  

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

# AWS Provider configuration
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}