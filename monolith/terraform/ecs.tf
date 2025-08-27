# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs role
## ------------------------------------------------------------#

resource "aws_iam_role" "ecs_task" {
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:ecs:ap-northeast-1:${local.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task.json

}

data "aws_iam_policy_document" "ecs_task" {

  # secretsmangerからの環境変数取得用権限
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }

  # ecs exec用権限
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }

  # ecs execログ保存用権限
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

}


resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

## ------------------------------------------------------------#
##  ecs task role
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "ecs_task" {
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task.json

}

data "aws_iam_policy_document" "ecs_task" {

  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "*"
    ]
  }

}


resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}
*/
## ------------------------------------------------------------#
##  ecs task exec role
## ------------------------------------------------------------#

resource "aws_iam_role" "ecs_task_exec" {
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_exec_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-exec-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "ecs_task_exec_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ecs_task_exec" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task_exec.json

}

data "aws_iam_policy_document" "ecs_task_exec" {

  # ecrからのイメージ取得用権限
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  # ssm secretsmanagerからの値参照用権限
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }

  # cloudwatchへのログ保存用権限
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

}


resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_task_exec.arn
}


# ------------------------------------------------------------#
#  cluster
# ------------------------------------------------------------#

resource "aws_ecs_cluster" "this" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
}

# ------------------------------------------------------------#
#  service
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  api
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

data "aws_ecs_task_definition" "api" {
  task_definition = aws_ecs_task_definition.api.family
}


resource "aws_ecs_task_definition" "api" {
  container_definitions = jsonencode([
    {
      name   = "api"
      image  = "${aws_ecr_repository.api.repository_url}:latest"
      cpu    = 1024
      memory = 2048
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-api"
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
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_ENV"
        },
        {
          name      = "SERVER_TYPE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_TYPE"
        },
        {
          name      = "SECRET_KEY_NAME"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/api/SECRET_KEY_NAME"
        },
        {
          name      = "DB_MIGRATE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-api-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}
*/
/*
resource "aws_ecs_service" "api" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "api"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.api.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-api-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.api.family}:${max(aws_ecs_task_definition.api.revision, data.aws_ecs_task_definition.api.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
## ------------------------------------------------------------#
##  app
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-app"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}

data "aws_ecs_task_definition" "app" {
  task_definition = aws_ecs_task_definition.app.family
}

resource "aws_ecs_task_definition" "app" {
  container_definitions = jsonencode([
    {
      name   = "app"
      image  = "${aws_ecr_repository.app.repository_url}:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-app"
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
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_ENV"
        },
        {
          name      = "SERVER_TYPE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_TYPE"
        },
        {
          name      = "DB_MIGRATE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-app-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}

resource "aws_ecs_service" "app" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "app"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.app.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-app-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.aws_ecs_task_definition.app.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
## ------------------------------------------------------------#
##  app bg
## ------------------------------------------------------------#
/*
resource "aws_ecs_service" "app" {
  cluster = aws_ecs_cluster.this.id

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "app"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.app["blue"].arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-app-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }
  launch_type         = "FARGATE"
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.app.family}:${max(aws_ecs_task_definition.app.revision, data.aws_ecs_task_definition.app.revision)}"

  lifecycle {
    # These properties will be changed dynamically during deployment by CodePipeline.
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer,
    ]
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}
*/
## ------------------------------------------------------------#
##  app2
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "app2" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-app2"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app2"
  }
}


data "aws_ecs_task_definition" "app2" {
  task_definition = aws_ecs_task_definition.app2.family
}

resource "aws_ecs_task_definition" "app2" {
  container_definitions = jsonencode([
    {
      name   = "app2"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bg-rp05:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-app2"
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
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_ENV"
        },
        {
          name      = "SERVER_TYPE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_TYPE"
        },
        {
          name      = "DB_MIGRATE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-app2-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app2"
  }
}
/*
resource "aws_ecs_service" "app2" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "app2"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.app2.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-app2-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.app2.family}:${max(aws_ecs_task_definition.app2.revision, data.aws_ecs_task_definition.app2.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app2"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
## ------------------------------------------------------------#
##  django
## ------------------------------------------------------------#
/*
data "aws_ecs_task_definition" "django" {
  task_definition = aws_ecs_task_definition.django.family
}

resource "aws_ecs_task_definition" "django" {
  container_definitions = jsonencode([
    {
      name   = "django"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${local.PJPrefix}/${local.EnvPrefix}/django:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-django"
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
          name      = "DATABASE"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/django:DATABASE::"
        },
        {
          name      = "DB_USER"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/django:DB_USER::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/django:DB_PASSWORD::"
        },
        {
          name      = "DB_HOST"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/django:DB_HOST::"
        },
        {
          name      = "DB_PORT"
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/api:DB_PORT::"
        },
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-django-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-django"
  }
}

resource "aws_ecs_service" "django" {
  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = aws_ecs_cluster.this.id

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "django"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.django.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-django-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.django.family}:${max(aws_ecs_task_definition.django.revision, data.aws_ecs_task_definition.django.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-django"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
## ------------------------------------------------------------#
##  migarate
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "migrate" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-migrate"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-migrate"
  }
}

data "aws_ecs_task_definition" "migrate" {
  task_definition = aws_ecs_task_definition.migrate.family
}

resource "aws_ecs_task_definition" "migrate" {
  container_definitions = jsonencode([
    {
      name   = "migrate"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bg-rp05:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-migrate"
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
      command = [
        "python",
        "migrate",
      ]
      secrets = [
        {
          name      = "SERVER_ENV"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_ENV"
        },
        {
          name      = "SERVER_TYPE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_TYPE"
        },
        {
          name      = "DB_MIGRATE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-migrate-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task.arn

}
*/