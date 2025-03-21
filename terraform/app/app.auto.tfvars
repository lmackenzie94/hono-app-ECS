# variables can also be set via CLI or in the HCP Terraform UI.
# this file is ideal for non-sensitive, shared default values that are common across environments.
# for secret/sensitive or environment-specific values, use HCP Terraform variables.

app_name = "hono-app-ecs"

# NOTE: Application Load Balancers (ALB) require at least two Availability Zones
num_availability_zones = 2
vpc_cidr               = "10.0.0.0/16"
container_port         = 3000
ecs_task_cpu           = 256
ecs_task_memory        = 512
ecs_task_desired_count = 1
logs_retention_days    = 3
domain_name            = "lukelearnsthe.cloud"
subdomain_name         = "hono-ecs"