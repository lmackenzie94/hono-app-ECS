output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "app_url" {
  description = "The URL of the application"
  value       = "https://${var.subdomain_name}.${var.domain_name}"
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.ecs_logs.cloudwatch_log_group_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.storage.dynamodb_table_arn
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  value       = module.storage.dynamodb_table_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
