# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#

resource "aws_ecs_cluster" "this" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
}

resource "aws_iam_role" "ecs-task" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"
  path                 = "/"
}

resource "aws_iam_policy" "ecs-task" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ecs-task-policy"
  path = "/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "ecr:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:GetRole",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${local.account_id}:role/${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"
    },
    {
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs-task" {
  role       = aws_iam_role.ecs-task.name
  policy_arn = aws_iam_policy.ecs-task.arn
}

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
data "aws_ecs_task_definition" "api" {
  task_definition = aws_ecs_task_definition.api.family
}

resource "aws_cloudwatch_log_group" "api" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
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
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-api-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

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
# ------------------------------------------------------------#
#  flask
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "flask" {
  task_definition = aws_ecs_task_definition.flask.family
}

resource "aws_cloudwatch_log_group" "flask" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-flask"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ecs_task_definition" "flask" {
  container_definitions = jsonencode([
    {
      name   = "flask"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bg-rp05:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-flask"
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
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-flask-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}
/*
resource "aws_ecs_service" "flask" {
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
    container_name   = "flask"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.flask.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-flask-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.flask.family}:${max(aws_ecs_task_definition.flask.revision, data.aws_ecs_task_definition.flask.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
# ------------------------------------------------------------#
#  flask bg
# ------------------------------------------------------------#
/*
resource "aws_ecs_service" "flask" {
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
    container_name   = "flask"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.flask["blue"].arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-flask-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }
  launch_type         = "FARGATE"
  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.flask.family}:${max(aws_ecs_task_definition.flask.revision, data.aws_ecs_task_definition.flask.revision)}"

  lifecycle {
    # These properties will be changed dynamically during deployment by CodePipeline.
    ignore_changes = [
      task_definition,
      desired_count,
      load_balancer,
    ]
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}
*/
# ------------------------------------------------------------#
#  flask2
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "flask2" {
  task_definition = aws_ecs_task_definition.flask2.family
}

resource "aws_cloudwatch_log_group" "flask2" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-flask2"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask2"
  }
}

resource "aws_ecs_task_definition" "flask2" {
  container_definitions = jsonencode([
    {
      name   = "flask2"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bg-rp05:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-flask2"
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
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-flask2-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask2"
  }
}
/*
resource "aws_ecs_service" "flask2" {
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
    container_name   = "flask2"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.flask2.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-flask2-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.flask2.family}:${max(aws_ecs_task_definition.flask2.revision, data.aws_ecs_task_definition.flask2.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask2"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
    ]
  }
}
*/
# ------------------------------------------------------------#
#  django-migration
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "django_migrate" {
  task_definition = aws_ecs_task_definition.django_migrate.family
}

resource "aws_cloudwatch_log_group" "django" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-django"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-django"
  }
}

resource "aws_ecs_task_definition" "django_migrate" {
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
      command = [
        "python",
        "manage.py",
        "migrate",
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
          valueFrom = "arn:aws:secretsmanager:ap-northeast-1:${local.account_id}:secret:${local.PJPrefix}/${local.EnvPrefix}/django:DB_PORT::"
        },
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-django-migrate-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-django"
  }
}

# ------------------------------------------------------------#
#  django
# ------------------------------------------------------------#
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
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-django-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

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
/*
# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "sync" {
  task_definition = aws_ecs_task_definition.sync.family
}

resource "aws_cloudwatch_log_group" "sync" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-sync"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

resource "aws_ecs_task_definition" "sync" {
  container_definitions = jsonencode([
    {
      name   = "sync"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/bg-rp05:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-sync"
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
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/SECRET_KEY_NAME_SYNC"
        },
        {
          name      = "DB_MIGRATE"
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
        },
        {
          name      = "SECRET_TEST"
          valueFrom = "${aws_secretsmanager_secret.sync_escape.arn}:::"
        },
        {
          name      = "CORS_ORIGIN_REGEX_WHITELIST"
          valueFrom = "${aws_secretsmanager_secret.sync_escape.arn}:CORS_ORIGIN_REGEX_WHITELIST::"
        },
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-sync-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

resource "aws_ecs_service" "sync" {
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
    container_name   = "sync"
    container_port   = "80"
    target_group_arn = aws_lb_target_group.sync.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-sync-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.sync.family}:${max(aws_ecs_task_definition.sync.revision, data.aws_ecs_task_definition.sync.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
      task_definition,
    ]
  }
}
*/

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "web" {
  task_definition = aws_ecs_task_definition.web.family
}

resource "aws_cloudwatch_log_group" "web" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-web"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}

resource "aws_ecs_task_definition" "web" {
  container_definitions = jsonencode([
    {
      name   = "web"
      image  = "${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${local.PJPrefix}/${local.EnvPrefix}/web:latest"
      cpu    = 256
      memory = 512
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-web"
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
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
          valueFrom = "/${local.PJPrefix}/${local.EnvPrefix}/web/SECRET_KEY_NAME"
        }
      ]
    }
  ])
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-web-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}
/*
resource "aws_ecs_service" "web" {
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
    container_name   = "web"
    container_port   = "3000"
    target_group_arn = aws_lb_target_group.web.arn
  }

  name = "${local.PJPrefix}-${local.EnvPrefix}-web-service"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = [aws_security_group.private.id]
    subnets          = data.aws_subnets.private.ids
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"
  task_definition     = "${aws_ecs_task_definition.web.family}:${max(aws_ecs_task_definition.web.revision, data.aws_ecs_task_definition.web.revision)}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      platform_version,
      task_definition,
    ]
  }
}
*/

# ------------------------------------------------------------#
#  migarate
# ------------------------------------------------------------#

data "aws_ecs_task_definition" "migrate" {
  task_definition = aws_ecs_task_definition.migrate.family
}

resource "aws_cloudwatch_log_group" "migrate" {
  name = "/ecs/${local.PJPrefix}-${local.EnvPrefix}-migrate"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-migrate"
  }
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
        "echo",
        "hello",
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
  execution_role_arn       = aws_iam_role.ecs-task.arn
  family                   = "${local.PJPrefix}-${local.EnvPrefix}-migrate-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs-task.arn

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}