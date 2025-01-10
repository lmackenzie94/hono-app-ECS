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

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod, etc.)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
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

variable "availability_zones" {
  description = "Availability zones for subnets"
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"] 
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16" # gives you 10.0.0.0 - 10.0.255.255 (65,536 IP addresses)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"] # gives you 10.0.1.0 - 10.0.1.255 and 10.0.2.0 - 10.0.2.255 (256 IP addresses each)
}