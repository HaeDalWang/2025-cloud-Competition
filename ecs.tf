# 클러스터
resource "aws_ecs_cluster" "skills_cluster" {
  name = "skills-cluster"
}

## 태스크 실행 롤
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ssm_secrets_access" {
  name = "ecs-execution-role-ssm-access"
  role = aws_iam_role.ecs_execution_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [
          aws_ssm_parameter.auth_token.arn,
          aws_ssm_parameter.ddb_table.arn,
          aws_ssm_parameter.region.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 태스크 롤
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_admin_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

## 태스크 정의에 들어갈 사양
locals {
  task_definitions = {
    frontend = {
      name          = "frontend"
      container_port = 8080
      host_port      = 8080
    }
    api = {
      name          = "api"
      container_port = 8888
      host_port      = 8888
    }
    auth = {
        name          = "auth"
      container_port = 3000
      host_port      = 3000
    }
  }
}

resource "aws_ecs_task_definition" "auth_task" {
  family                   = "skills-auth-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "auth-server"
      image     = "863422182520.dkr.ecr.ap-northeast-2.amazonaws.com/auth:latest"
      essential = true
      cpu       = 256
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "AUTH_TOKEN"
          valueFrom = aws_ssm_parameter.auth_token.arn
        },
        {
          name      = "DDB_TABLE_NAME"
          valueFrom = aws_ssm_parameter.ddb_table.arn
        },
        {
          name      = "AWS_REGION"
          valueFrom = aws_ssm_parameter.region.arn
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "api_task" {
  family                   = "skills-api-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "api-server"
      image = "863422182520.dkr.ecr.ap-northeast-2.amazonaws.com/api:latest"
      portMappings = [{ containerPort = 8888, hostPort = 8888 }]
    }
  ])
}

resource "aws_ecs_task_definition" "front_task" {
  family                   = "skills-front-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "frontend-server"
      image = "863422182520.dkr.ecr.ap-northeast-2.amazonaws.com/frontend:latest"
      portMappings = [{ containerPort = 8080, hostPort = 8080 }]
    }
  ])
}