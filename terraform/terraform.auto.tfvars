# variables can also be set via CLI or in the HCP Terraform UI.
# this file is ideal for non-sensitive, shared default values that are common across environments.
# for secret/sensitive or environment-specific values, use HCP Terraform variables.

aws_region             = "us-east-1"
vpc_cidr               = "10.0.0.0/16"
availability_zones     = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
app_name               = "hono-app"
environment            = "dev"
container_port         = 3000
ecs_task_cpu           = 256
ecs_task_memory        = 512
ecs_task_desired_count = 1
logs_retention_days    = 5
domain_name            = "lukelearnsthe.cloud"
subdomain_name         = "hono-ecs"