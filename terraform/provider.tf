# --------------------------------------
# AWS Provider configuration
# This file configures the AWS provider with the specified region and profile.
# It serves as the main connection point to AWS for all other resources.
# --------------------------------------

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}