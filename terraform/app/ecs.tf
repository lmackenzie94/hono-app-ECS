# --------------------------------------
# Amazon Elastic Container Service (ECS) configuration
# Defines the ECS cluster, task definitions, and services required to run the application.
# Includes container definitions, CPU/memory allocations, and service deployment settings.
# --------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  tags = {
    Name = "${var.app_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  depends_on = [
    module.ecs_logs
  ]

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${data.aws_ecr_repository.app.repository_url}:latest" # should match the output name in the storage module
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DYNAMODB_TABLE_NAME"
          value = module.storage.dynamodb_table_name # should match the output name in the storage module
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.name
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.app_name}-task-definition"
  }
}

resource "aws_ecs_service" "app" {
  name                 = "${var.app_name}-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.app.arn
  desired_count        = var.ecs_task_desired_count
  launch_type          = "FARGATE"
  force_new_deployment = true # force a new deployment if the task definition changes

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [module.ecs_tasks_sg.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]

  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION" # or "SERVICE"

  tags = {
    Name = "${var.app_name}-service"
  }
}
