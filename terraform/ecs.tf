# --------------------------------------
# Amazon Elastic Container Service (ECS) configuration
# Defines the ECS cluster, task definitions, and services required to run the application.
# Includes container definitions, CPU/memory allocations, and service deployment settings.
# --------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = var.ecs_task_cpu
  memory                  = var.ecs_task_memory
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn
  depends_on = [
    aws_cloudwatch_log_group.ecs_logs
  ]
  
  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DYNAMODB_TABLE_NAME"
          value = aws_dynamodb_table.app_table.name
        },
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.app_name}-task-definition"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.app.arn
  desired_count   = var.ecs_task_desired_count
  launch_type     = "FARGATE"
  force_new_deployment = true # force a new deployment if the task definition changes

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

   load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]

  enable_ecs_managed_tags = true
  propagate_tags         = "TASK_DEFINITION"  # or "SERVICE"

  tags = {
    Name        = "${var.app_name}-service"
    Environment = var.environment
    Application = var.app_name
  }
}
