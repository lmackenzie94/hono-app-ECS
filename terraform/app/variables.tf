variable "app_name" {
  description = "Name of the application"
  type        = string
  validation {
    condition     = length(var.app_name) > 0
    error_message = "Application name cannot be empty."
  }
}

variable "container_port" {
  description = "Port the container will listen on"
  type        = number
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "ecs_task_desired_count" {
  description = "Desired number of tasks to run"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task"
  type        = number
}

variable "logs_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "num_availability_zones" {
  description = "Number of availability zones to create"
  type        = number
  default     = 2

  validation {
    condition     = var.num_availability_zones >= 2 && var.num_availability_zones <= 3
    error_message = "Number of availability zones must be at least 2 and no more than 3."
  }
}

variable "subdomain_name" {
  description = "Subdomain name for the application"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16" # gives you 10.0.0.0 - 10.0.255.255 (65,536 IP addresses)
}
