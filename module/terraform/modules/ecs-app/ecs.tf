# ------------------------------------------------------------#
#  task definition
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  app
## ------------------------------------------------------------#

data "aws_ecs_task_definition" "app" {
  task_definition = aws_ecs_task_definition.app.family
}

resource "aws_ecs_task_definition" "app" {
  container_definitions = jsonencode([
    {
      name   = "${var.app_name}"
      image  = "${aws_ecr_repository.app.repository_url}:latest"
      cpu    = var.container_cpu
      memory = var.container_memory
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "SERVER_ENV"
          valueFrom = "/${var.pj_prefix}/${var.env_prefix}/SERVER_ENV"
        },
        {
          name      = "SERVER_TYPE"
          valueFrom = "/${var.pj_prefix}/${var.env_prefix}/SERVER_TYPE"
        }
      ]
    }
  ])
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  family                   = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]


  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }
}

# ------------------------------------------------------------#
#  service
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  app
## ------------------------------------------------------------#

resource "aws_ecs_service" "app" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = var.cluster

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "${var.app_name}"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.app.arn
  }

  name = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-service"

  network_configuration {
    assign_public_ip = "false"
    security_groups  = [var.private_security_group_id]
    subnets          = var.private_subnet_ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.aws_ecs_task_definition.app.revision)}"

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}
/*
resource "aws_appautoscaling_scheduled_action" "app_schedule_up" {
  name               = "${var.pj_prefix}-${var.env_prefix}-app-schedule-up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(00 8 ? * MON-FRI *)"
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    min_capacity = var.app_ecs_up_min_capacity
    max_capacity = var.app_ecs_up_max_capacity
  }
}

resource "aws_appautoscaling_scheduled_action" "app_schedule_down" {
  name               = "${var.pj_prefix}-${var.env_prefix}-app-schedule-down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  schedule           = "cron(00 20 ? * MON-FRI *)"
  timezone           = "Asia/Tokyo"

  scalable_target_action {
    min_capacity = var.app_ecs_down_min_capacity
    max_capacity = var.app_ecs_down_max_capacity
  }
}

resource "aws_appautoscaling_policy" "app_cpu_target" {
  name               = "${var.pj_prefix}-${var.env_prefix}-app-cpu-target"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.app.service_namespace
  resource_id        = aws_appautoscaling_target.app.resource_id
  scalable_dimension = aws_appautoscaling_target.app.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    # albのderegistration_delayを900秒に設定しているため、scale_in_cooldownをそれより大きく設定する
    scale_in_cooldown  = 1000
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "app_memory_target" {
  name               = "${var.pj_prefix}-${var.env_prefix}-app-memory-target"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.app.service_namespace
  resource_id        = aws_appautoscaling_target.app.resource_id
  scalable_dimension = aws_appautoscaling_target.app.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 60
    # albのderegistration_delayを900秒に設定しているため、scale_in_cooldownをそれより大きく設定する
    scale_in_cooldown  = 1000
    scale_out_cooldown = 60
  }
}
*/
