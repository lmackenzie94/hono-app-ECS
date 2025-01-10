# --------------------------------------
# Identity and Access Management (IAM) configuration
# Sets up the necessary IAM roles and policies for ECS tasks.
# Includes both the task execution role (for ECS operations) and the task role (for application permissions).
# --------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-execution-role"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-task-role"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_iam_role_policy" "ecs_task_dynamodb" {
  name = "ecs_task_dynamodb"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          # "dynamodb:DeleteItem",
          # "dynamodb:Scan",
          # "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.app_table.arn
      }
    ]
  })
}