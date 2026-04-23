resource "aws_ecs_cluster" "main" {
  name = "paperclip-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

resource "aws_cloudwatch_log_group" "paperclip" {
  name              = "/ecs/paperclip/${var.environment}/server"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_ecs_task_definition" "paperclip" {
  family                   = "paperclip-${var.environment}-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  volume {
    name = "paperclip-data"

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049

      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name  = "paperclip"
      image = "${var.ecr_repository_url}:${var.image_tag}"

      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "paperclip-data"
          containerPath = "/paperclip"
          readOnly      = false
        }
      ]

      environment = concat(
        [
          { name = "NODE_ENV", value = "production" },
          { name = "PORT", value = tostring(var.container_port) },
          { name = "HOST", value = "0.0.0.0" },
          { name = "SERVE_UI", value = "true" },
          { name = "PAPERCLIP_HOME", value = "/paperclip" },
          { name = "PAPERCLIP_DEPLOYMENT_MODE", value = "authenticated" },
          { name = "PAPERCLIP_DEPLOYMENT_EXPOSURE", value = "public" },
          { name = "PAPERCLIP_PUBLIC_URL", value = var.paperclip_public_url },
          { name = "PAPERCLIP_API_URL", value = var.paperclip_public_url },
          { name = "PAPERCLIP_TELEMETRY_DISABLED", value = "1" },
          { name = "NODE_TLS_REJECT_UNAUTHORIZED", value = "0" },
          { name = "GIT_AUTHOR_NAME", value = "Rosh Singh" },
          { name = "GIT_AUTHOR_EMAIL", value = "roshsingh81@gmail.com" },
          { name = "GIT_COMMITTER_NAME", value = "Rosh Singh" },
          { name = "GIT_COMMITTER_EMAIL", value = "roshsingh81@gmail.com" },
        ],
        var.paperclip_allowed_hostnames != "" ? [{ name = "PAPERCLIP_ALLOWED_HOSTNAMES", value = var.paperclip_allowed_hostnames }] : []
      )

      secrets = var.ecs_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.paperclip.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "paperclip"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -fsS http://localhost:${var.container_port}/health >/dev/null || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 120
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "paperclip" {
  name            = "paperclip-${var.environment}-server"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.paperclip.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "paperclip"
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [var.alb_listener_arn]

  tags = var.tags
}
