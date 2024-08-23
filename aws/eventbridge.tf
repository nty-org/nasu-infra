# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#
resource "aws_iam_role" "eventbridge_scheduler" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "scheduler.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns  = ["${aws_iam_policy.eventbridge_scheduler.arn}"]
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-scheduler-role"
  path                 = "/"
}

resource "aws_iam_policy" "eventbridge_scheduler" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-scheduler-policy"
  path = "/"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "rds:StartDBCluster",
        "rds:StopDBCluster"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:StopInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

# ------------------------------------------------------------#
#  rds
# ------------------------------------------------------------#
/*
resource "aws_scheduler_schedule" "rds_start" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-rds-start"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(12 21 ? * MON-FRI *)"
  state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${aws_rds_cluster.this.id}"
    })
  }
}

resource "aws_scheduler_schedule" "rds_stop" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-rds-stop"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(50 16 ? * MON-FRI *)"
  #state = "DISABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      DbClusterIdentifier = "${aws_rds_cluster.this.id}"
    })
  }
}
*/
# ------------------------------------------------------------#
#  ec2
# ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ec2_stop" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-ec2-stop"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 12 ? * MON-FRI *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = "arn:aws:iam::267751904634:role/nasu-prod-eventbridge-scheduler-role"

    input = jsonencode({
      InstanceIds = ["i-0d52296bbbb9a97b4"]
    })
  }
}
/*
# ------------------------------------------------------------#
#  ecs
# ------------------------------------------------------------#

resource "aws_scheduler_schedule" "ecs_start" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-ecs-start"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }


  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(30 13 ? * MON-FRI *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      Service      = "${aws_ecs_service.sync.name}",
      Cluster      = "${aws_ecs_cluster.this.id}",
      DesiredCount = 1
    })
  }
}

resource "aws_scheduler_schedule" "ecs_stop" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-ecs-stop"
  #group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }
  

  schedule_expression_timezone = "Asia/Tokyo"
  schedule_expression          = "cron(00 14 ? * MON-FRI *)"
  #state = "ENABLED"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ecs:updateService"
    role_arn = "${aws_iam_role.eventbridge_scheduler.arn}"

    input = jsonencode({
      Service      = "${aws_ecs_service.sync.name}",
      Cluster      = "${aws_ecs_cluster.this.id}",
      DesiredCount = 0
    })
  }
}
*/
/*
# ------------------------------------------------------------#
#  ecs scheduled task role
# ------------------------------------------------------------#

resource "aws_iam_role" "ecs_scheduled_task" {
  assume_role_policy    = data.aws_iam_policy_document.ecs_scheduled_task_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-ecs-scheduled-task-role"
  path                  = "/"
}

data "aws_iam_policy_document" "ecs_scheduled_task_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_scheduled_task" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ecs-scheduled-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_scheduled_task.json
}

data "aws_iam_policy_document" "ecs_scheduled_task" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      "${aws_ecs_task_definition.daily_update_sessions_success.arn_without_revision}:*",
      "*",
    ]
  }

}

resource "aws_iam_role_policy_attachment" "ecs_scheduled_task" {
  role       = aws_iam_role.ecs_scheduled_task.name
  policy_arn = aws_iam_policy.ecs_scheduled_task.arn
}

# ------------------------------------------------------------#
#  ecs scheduled task
# ------------------------------------------------------------#

resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-daily-update-sessions-success"
  schedule_expression = "cron(13 2 ? * SUN *)"
  state               = "ENABLED"
}


resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-daily-update-sessions-success"
  arn       = aws_ecs_cluster.this.arn
  rule      = aws_cloudwatch_event_rule.ecs_scheduled_task.name
  role_arn  = aws_iam_role.ecs_scheduled_task.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.daily_update_sessions_success.arn_without_revision
    launch_type         = "FARGATE"
    platform_version    = "1.4.0"
    network_configuration {
      assign_public_ip = false
      security_groups  = [aws_security_group.private.id,"sg-0e737a79a698834f6"]
      subnets          = data.aws_subnets.private.ids
    }
  }

  input = jsonencode({
    containerOverrides = [
      {
        name = "api",
        command = [
          "poetry",
          "run",
          "python",
          "/code/job/daily_update_sessions_success.py",
        ]
      }
    ]
  })
}
*/