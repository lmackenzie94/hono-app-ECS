output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "app_url" {
  description = "The URL of the application"
  value       = "https://${var.subdomain_name}.${var.domain_name}"
}

# DynamoDB outputs (from storage module)
# These only work because I've added them as outputs in the storage module (see `modules/storage/outputs.tf`)
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = module.storage.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.storage.dynamodb_table_arn
}

# CloudWatch outputs (from Cloudwatch/log-group module)
# https://registry.terraform.io/modules/terraform-aws-modules/cloudwatch/aws/latest/submodules/log-group?tab=outputs
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.ecs_logs.cloudwatch_log_group_name
}
