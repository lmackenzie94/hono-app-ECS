# Hono Counter App with AWS ECS

https://hono-ecs.lukelearnsthe.cloud

This is a simple Hono Node.js application that implements a view counter using AWS DynamoDB and is deployed on AWS ECS Fargate.

## Architecture

- **Application**: Node.js app using Hono framework
- **Database**: AWS DynamoDB (serverless, pay-per-request mode)
- **Container Orchestration**: AWS ECS with Fargate launch type
- **Infrastructure**: Defined using Terraform
- **Load Balancing**: Application Load Balancer with two tasks for high availability

## Cost Optimization

1. Using DynamoDB with pay-per-request pricing mode for minimal database costs
2. Fargate launch type eliminates need for managing EC2 instances
3. Minimal CPU (0.25 vCPU) and memory (0.5GB) allocation per task
4. Using Node.js 18 slim image to reduce container size

## Deploying the application

1. `docker build --platform linux/amd64 -t hono-app .`
2. `docker tag hono-app:latest 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
3. `docker push 021891593951.dkr.ecr.us-east-1.amazonaws.com/hono-app:latest`
4. `aws ecs update-service --cluster hono-app-cluster --service hono-app-service --force-new-deployment --profile admin --region us-east-1`

## Updating the infrastructure

1. `terraform plan`
2. `terraform apply`

## Infrastructure Components

- ECS Cluster running on Fargate
- DynamoDB table for storing the counter
- Application Load Balancer
- Security Groups and IAM roles
- ACM Certificate for SSL/TLS
- Route 53 DNS records for the subdomain
- CloudWatch Logs for monitoring
