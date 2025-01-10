# --------------------------------------
# Variables configuration
# Declares all variables used across the Terraform configuration.
# Defines variable types, descriptions, and any default values.
# These variables can be set via terraform.tfvars or environment variables.
# --------------------------------------

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "admin"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
}

variable "container_port" {
  description = "Port the container will listen on"
  type        = number
}

variable "ecs_task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
}

variable "ecs_task_memory" {
  description = "Memory for the ECS task"
  type        = number
}

variable "ecs_task_desired_count" {
  description = "Desired number of tasks to run"
  type        = number
}

variable "logs_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}
