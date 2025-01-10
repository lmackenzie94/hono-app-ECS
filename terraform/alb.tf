# --------------------------------------
# Application Load Balancer (ALB) configuration
# Sets up the ALB and target group for our application.
# --------------------------------------

resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.app_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval           = "60"
    protocol           = "HTTP"
    matcher            = "200"
    timeout            = "3"
    path              = "/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.app_name}-tg"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
