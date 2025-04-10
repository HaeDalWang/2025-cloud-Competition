# 엘비 보안그룹이랑 엘비
resource "aws_security_group" "skills_alb_sg" {
  name        = "skills-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "skills_alb" {
  name               = "skills-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.skills_alb_sg.id]
  subnets            = module.vpc.public_subnets
}

# 타겟그룹
resource "aws_lb_target_group" "frontend" {
  name        = "skills-frontend-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "api" {
  name        = "skills-api-tg"
  port        = 8888
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "auth" {
  name        = "skills-auth-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

# 리스너
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.skills_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

# 리스너 룰
resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/home*"]
    }
  }
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/api*", "/v1*"]
    }
  }
}

resource "aws_lb_listener_rule" "auth_rule" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth*"]
    }
  }
}
