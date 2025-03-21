# --------------------------------------
# AWS Provider configuration
# This file configures the AWS provider with the specified region.
# It serves as the main connection point to AWS for all other resources.
# --------------------------------------

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Application = var.app_name
      Environment = terraform.workspace
    }
  }
}