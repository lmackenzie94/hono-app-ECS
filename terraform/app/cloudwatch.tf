# --------------------------------------
# Amazon CloudWatch configuration
# Configures logging infrastructure for the application.
# Sets up log groups and retention policies for ECS task logs.
# --------------------------------------

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.logs_retention_days

  tags = {
    Name = "${var.app_name}-logs"
  }
}