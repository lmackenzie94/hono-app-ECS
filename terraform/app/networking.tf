# --------------------------------------
# AWS Networking configuration (WITH modules)
# Establishes the VPC, subnets, internet gateway, route tables, and security groups.
# Creates the network infrastructure required for the ECS tasks to run and communicate.
# --------------------------------------

# --------------------------------------
# VPC
# --------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17"

  name = "${var.app_name}-vpc"
  cidr = var.vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, var.num_availability_zones)
  public_subnets = [for i in range(var.num_availability_zones) : cidrsubnet(var.vpc_cidr, 8, i + 1)]

  # OPTIONAL INPUTS:
  # enable_dns_hostnames = true (default) - allows DNS hostnames to be used in the VPC
  # enable_dns_support   = true (default) - enables DNS resolution in the VPC
  # create_igw = true (default) - creates an internet gateway for public subnets
  # enable_nat_gateway = false (default) - disables NAT gateways b/c we only need public subnets
  # single_nat_gateway = false (default) - disables single NAT gateway b/c we only need public subnets
  # enable_vpn_gateway = false (default) - disables VPN gateways b/c we don't need VPN

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

# --------------------------------------
# Security groups
# --------------------------------------
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.app_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.vpc.vpc_id

  # allow inbound traffic from the internet...
  ingress_with_cidr_blocks = [
    # ...on port 80 (HTTP), which will be redirected to port 443 by the ALB HTTP Listener
    {
      description = "Allow all inbound HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0" # allow traffic from anywhere
    },
    # ...on port 443 (HTTPS), which will be forwarded to the target group by the ALB HTTPS Listener
    {
      description = "Allow all inbound HTTPS traffic"

      # to open a single port (443), from_port and to_port must be the same:
      from_port = 443
      to_port   = 443

      # to open a range of ports (443-445), specify the range:
      # from_port   = 443
      # to_port     = 445

      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # allow outbound traffic to the internet
  egress_with_cidr_blocks = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1" # all protocols
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}

module "ecs_tasks_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = "${var.app_name}-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  # allow inbound traffic from the ALB
  ingress_with_source_security_group_id = [
    {
      description              = "Allow inbound traffic from the ALB"
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  # allow outbound traffic to the internet
  egress_with_cidr_blocks = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1" # all protocols
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "${var.app_name}-sg"
  }
}
