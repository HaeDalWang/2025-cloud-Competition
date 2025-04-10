resource "aws_cloudwatch_log_group" "app_logs" {
  for_each          = toset(local.app)
  name              = "/skills-cluster/app/${each.key}"
  retention_in_days = 30

  tags = {
    Name = "skills-app-logs"
  }
}

# 앱 마다 쓸 보안그룹
resource "aws_security_group" "skills_sg" {
  for_each = toset(local.app)

  name        = "skills-${each.key}-sg"
  description = "${each.key} service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = local.task_definitions[each.key].container_port
    to_port     = local.task_definitions[each.key].container_port
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

# 앱별 서비스
resource "aws_ecs_service" "skills_api_services" {
  name            = "skills-api-service"
  cluster         = aws_ecs_cluster.skills_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.skills_sg["api"].id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api-server"
    container_port   = local.task_definitions["api"].container_port
  }
  depends_on = [ aws_lb_listener.main ]
}

resource "aws_ecs_service" "skills_auth_services" {
  name            = "skills-auth-service"
  cluster         = aws_ecs_cluster.skills_cluster.id
  task_definition = aws_ecs_task_definition.auth_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.skills_sg["auth"].id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.auth.arn
    container_name   = "auth-server"
    container_port   = local.task_definitions["auth"].container_port
  }
  service_registries {
    registry_arn = aws_service_discovery_service.auth_service_discovery.arn
  }
  depends_on = [ aws_lb_listener.main ]
}

resource "aws_ecs_service" "skills_frontend_services" {
  name            = "skills-frontend-service"
  cluster         = aws_ecs_cluster.skills_cluster.id
  task_definition = aws_ecs_task_definition.front_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.skills_sg["frontend"].id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend-server"
    container_port   = local.task_definitions["frontend"].container_port
  }

  depends_on = [ aws_lb_listener.main ]
}