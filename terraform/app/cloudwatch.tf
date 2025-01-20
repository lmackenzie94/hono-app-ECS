# --------------------------------------
# Amazon CloudWatch configuration
# Configures logging infrastructure for the application.
# Sets up log groups and retention policies for ECS task logs.
# --------------------------------------

# OPTION 1: create using AWS provider 
# resource "aws_cloudwatch_log_group" "ecs_logs" {
#   name              = "/ecs/${var.app_name}"
#   retention_in_days = var.logs_retention_days

#   tags = {
#     Name = "${var.app_name}-logs"
#   }
# }

# OPTION 2: create using the AWS "CloudWatch" module from the Terraform registry
# more specifically, the "log-group" sub-module
# https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/log-group

module "ecs_logs" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "5.7.0"

  name              = "/ecs/${var.app_name}"
  retention_in_days = var.logs_retention_days

  tags = {
    Name = "${var.app_name}-logs"
  }
}