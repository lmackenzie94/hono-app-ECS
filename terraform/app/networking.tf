# --------------------------------------
# AWS Networking configuration
# Establishes the VPC, subnets, internet gateway, route tables, and security groups.
# Creates the network infrastructure required for the ECS tasks to run and communicate.
# --------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count  = var.num_availability_zones
  vpc_id = aws_vpc.main.id
  # use vpc_cidr and shifts the CIDR block by 8 bits (10.0.0.0/16 -> 10.0.0.0/24)
  # the following will create a list of 2 CIDR blocks: ["10.0.1.0/24", "10.0.2.0/24"]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1) # without "+ 1", first CIDR block would be "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-${count.index}"
  }
}

# Internet Gateway
# is a virtual router that connects the VPC to the internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # the VPC to attach the Internet Gateway to

  tags = {
    Name = "${var.app_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # the VPC to attach the route table to

  # send all internet-bound traffic through the internet gateway
  route {
    cidr_block = "0.0.0.0/0" # all IPv4 traffic
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.app_name}-public-rt"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public" {
  count          = var.num_availability_zones
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.app_name}-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = "tcp"
    from_port = var.container_port
    to_port   = var.container_port
    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb.id] # Allow inbound traffic from the ALB
  }

  egress {
    protocol    = "-1" # all protocols
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # allow inbound traffic on port 80, which will be redirected to port 443 by the ALB HTTP Listener
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow inbound traffic on port 443, which will be forwarded to the target group by the ALB HTTPS Listener
  ingress {
    # NOTE: to open a single port (443), from_port and to_port must be the same:
    from_port = 443
    to_port   = 443

    # to open a range of ports (443-445), use the following:
    # from_port   = 443
    # to_port     = 445

    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb-sg"
  }
}