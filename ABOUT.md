# Deploying a Container Application to AWS ECS using Terraform

**Terraform** is an open-source infrastructure as code tool that allows you to define, provision, and manage your infrastructure resources in a declarative way. It provides a consistent way to manage your infrastructure across different environments, such as development, staging, and production.

**AWS ECS** is a container orchestration service that allows you to run and scale containerized applications on AWS. It provides a managed environment for running Docker containers and scaling your applications across multiple instances.

**AWS Fargate** is a serverless compute engine that allows you to run containers without managing the underlying infrastructure. It provides a fully managed environment for running Docker containers and scaling your applications across multiple instances.

This is a more cost-effective and scalable alternative to setting up and managing your own EC2 instances.

**AWS ECR** is a container registry service that allows you to store, manage, and deploy your Docker images on AWS. It provides a secure and scalable way to store and manage your Docker images.

**AWS ALB** is an Application Load Balancer that distributes traffic across multiple targets, such as ECS tasks. It provides a scalable and reliable way to distribute traffic across your ECS tasks.

## Project Structure

Our Terraform configuration is organized into several files, each handling specific aspects of the infrastructure:

```
terraform/
├── provider.tf
├── networking.tf
├── iam.tf
├── ecr.tf
├── ecs.tf
├── dynamodb.tf
├── alb.tf
├── acm.tf
├── cloudwatch.tf
├── variables.tf
├── outputs.tf
└── dev.auto.tfvars
```

**The infrastructure created includes:**

- VPC with public subnets

- ECS Cluster with Fargate

- ECR Repository

- IAM roles and policies

- DynamoDB table

- Security groups

- Application Load Balancer

- ACM Certificate for HTTPS

- CloudWatch log groups

## Provider

The `provider.tf` file configures the AWS provider with the specified region and profile.

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

## Networking Setup

The `networking.tf` file sets up our VPC and networking components like subnets, internet gateway, route tables, and security groups.

**VPC**

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

**Public Subnet**

```hcl
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}
```

**Internet Gateway**

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

**Route Table**

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
```

**Route Table Association**

```hcl
resource "aws_route_table_association" "public" {
  count           = length(var.availability_zones)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

**Security Group for ECS Tasks**

```hcl
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb.id] # Allow inbound traffic from the ALB
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Security Group for ALB**

Allows inbound traffic from the internet on port 80 (HTTP) and 443 (HTTPS).

```hcl
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

This creates a VPC with public subnets across multiple availability zones for high availability. The security group for the ALB allows inbound traffic from the internet. The security group for the ECS tasks allows inbound traffic from the ALB.

## IAM Roles and Permissions

The `iam.tf` file defines the necessary IAM roles for ECS:

**ECS Task Execution Role**

```hcl
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
}
```

**ECS Task Execution Role Policy Attachment**

```hcl
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```

**ECS Task Role**

```hcl
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
}
```

**ECS Task Role Policy**

```hcl
resource "aws_iam_role_policy" "ecs_task_dynamodb" {
  name = "ecs_task_dynamodb"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
        ]
        Resource = aws_dynamodb_table.app_table.arn
      }
    ]
  })
}
```

## Container Registry

The `ecr.tf` file creates an Elastic Container Registry to store our Docker images:

**ECR Repository**

```hcl
resource "aws_ecr_repository" "app" {
  name = var.app_name

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

## ECS Cluster and Service

The ecs.tf file defines our ECS cluster, task definition, and service:

**ECS Cluster**

```hcl
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}
```

**ECS Task Definition**

```hcl
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
}
```

**ECS Service**

```hcl
resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
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
}
```

## DynamoDB Table

If your application needs a database, `dynamodb.tf` creates a DynamoDB table:

**DynamoDB Table**

```hcl
resource "aws_dynamodb_table" "app_table" {
  name           = "${var.app_name}-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
```

## Application Load Balancer

The `alb.tf` file creates an Application Load Balancer to distribute traffic across our ECS tasks:

**Application Load Balancer**

```hcl
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
}
```

**Target Group**

```hcl
resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }
}
```

**HTTPS Listener**

Listens for HTTPS traffic on port 443 and forwards it to the target group. Also registers the ACM certificate with the ALB.

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  # wait for the certificate to be validated before creating the listener
  depends_on = [aws_acm_certificate_validation.cert]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

**HTTP Listener**

Redirects HTTP traffic on port 80 to HTTPS on port 443.

```hcl
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}
```

## Domain & ACM Certificate

The `acm.tf` file creates an ACM certificate for our domain:

**ACM Certificate**

```hcl
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.subdomain_name}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
```

**A Record**

Pointing the subdomain to the ALB.

```hcl
resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
```

## CloudWatch Logs

The `cloudwatch.tf` file creates a CloudWatch log group for our ECS tasks:

**CloudWatch Log Group**

```hcl
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.logs_retention_days
}
```

## Variables

The `variables.tf` file defines all the configurable parameters and optionally sets default values:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# ... more variables
```

The `dev.auto.tfvars` file contains the values for our variables:

```hcl
app_name = "my-app"
environment = "dev"

# ... more variable values
```

> When running Terraform CLI commands, we don't have to specify the `-var-file` flag because `.auto.tfvars` tells Terraform to automatically use the variables in this file.

## Outputs

The `outputs.tf` file defines the outputs for our Terraform configuration:

```hcl
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

# ... more outputs
```

## Deployment Process

**Initialize Terraform (only once):**

```bash
terraform init
```

**Plan the deployment:**

> The `-out` flag is used to save the plan to a file. This ensures the exact changes you reviewed are what gets applied.

```bash
terraform plan -out=tfplan
```

**Apply the configuration:**

```bash
terraform apply tfplan
```

**Build and push your Docker image (if it changed):**

```bash
docker build --platform linux/amd64 -t your-app .
docker tag your-app:latest $ECR_REPO_URL:latest
docker push $ECR_REPO_URL:latest
```

> Have to explicitly build for linux/amd64 platform because I'm using an Apple Silicon Mac which creates an ARM-based image but AWS Fargate runs on x86_64 (amd64) architecture.

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Best Practices

- Use separate `tfvars` files for different environments

- Implement proper tagging strategy

- Use multiple availability zones for high availability

- Implement proper health checks

- Set up monitoring and logging

- Use proper security groups and network ACLs

- Implement proper backup and disaster recovery strategies
