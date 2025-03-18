# [Hono Counter App with AWS ECS](https://hono-ecs.lukelearnsthe.cloud)

_A simple Hono Node.js application that implements a view counter using AWS DynamoDB. Deployed on AWS ECS Fargate._

---

- **Application**: Node.js app using Hono framework
- **Database**: AWS DynamoDB (serverless, pay-per-request mode)
- **Container Orchestration**: AWS ECS with Fargate launch type
- **Infrastructure**:
  - Defined using Terraform with HCP Terraform
  - Split into separate workspaces for ECR and ECS
  - Uses official AWS modules for VPC, CloudWatch, and Security Groups
- **Load Balancing**:
  - Application Load Balancer with HTTPS support
  - Custom domain with ACM certificate
  - Health checks on `/health` endpoint
- **Networking**:
  - VPC with public subnets across multiple AZs
  - Internet Gateway for public access
  - Security groups for ALB and ECS tasks
- **Monitoring & Logging**:
  - CloudWatch Logs for container output
  - ECR image scanning enabled
  - ECR lifecycle policies to manage images
