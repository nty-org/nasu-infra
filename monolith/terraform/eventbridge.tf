# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  eventbrige scheduler
## ------------------------------------------------------------#

resource "aws_iam_role" "eventbridge_scheduler" {
  assume_role_policy   = data.aws_iam_policy_document.eventbridge_scheduler_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-scheduler-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "eventbridge_scheduler_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "eventbridge_scheduler" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-scheduler-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eventbridge_scheduler.json
}

data "aws_iam_policy_document" "eventbridge_scheduler" {

  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "rds:StartDBCluster",
      "rds:StopDBCluster"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "eventbridge_scheduler" {
  role       = aws_iam_role.eventbridge_scheduler.name
  policy_arn = aws_iam_policy.eventbridge_scheduler.arn
}

## ------------------------------------------------------------#
##  eventbridge rule sns target
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "eventbridge_rule_sns_target" {
  assume_role_policy    = data.aws_iam_policy_document.eventbridge_rule_sns_target_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-rule-sns-target-role"
  path                  = "/service-role/"
}

data "aws_iam_policy_document" "eventbridge_rule_sns_target_assume_role_policy" {
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

resource "aws_iam_policy" "eventbridge_rule_sns_target" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-rule-sns-target-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.eventbridge_rule_sns_target.json
}

data "aws_iam_policy_document" "eventbridge_rule_sns_target" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "${aws_sns_topic.slack.arn}",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge_rule_sns_target" {
  role       = aws_iam_role.eventbridge_rule_sns_target.name
  policy_arn = aws_iam_policy.eventbridge_rule_sns_target.arn
}
*/
## ------------------------------------------------------------#
##  ecs scheduled task role
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "ecs_scheduled_task" {
  assume_role_policy    = data.aws_iam_policy_document.ecs_scheduled_task_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-ecs-scheduled-task-role"
  path                  = "/service-role/"
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
*/
# ------------------------------------------------------------#
#  eventbrige scheduler
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  rds auto start
## ------------------------------------------------------------#
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

## ------------------------------------------------------------#
##  rds auto stop
## ------------------------------------------------------------#

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
## ------------------------------------------------------------#
##  ec2 auto stop
## ------------------------------------------------------------#

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

## ------------------------------------------------------------#
##  ecs auto start
## ------------------------------------------------------------#
/*
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

## ------------------------------------------------------------#
##  ecs auto stop
## ------------------------------------------------------------#

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
# ------------------------------------------------------------#
#  eventbrige rule
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs abnormal stop detection
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "ecs_abnormal_stop" {
  name = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_cloudwatch_event_rule" "ecs_abnormal_stop" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.ecs"
    ],
    "detail-type": [
      "ECS Task State Change"
    ],
    "detail": {
      "clusterArn": ["${aws_ecs_cluster.this.arn}"],
      "$or": [{
        "containers": {
          "exitCode": [{ "anything-but": 0 }]
        }
      },
      {
        "stoppedReason": [{ "anything-but": { "prefix": "Scaling activity initiated by (deployment ecs-svc" } }]
      }],
      "lastStatus": ["STOPPED"], 
      "taskDefinitionArn" : [{ "prefix": "${aws_ecs_task_definition.flask.arn_without_revision}"}]
    }
  }
  EOT
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_log" {
  depends_on     = [
    aws_cloudwatch_event_rule.ecs_abnormal_stop,
    aws_cloudwatch_log_group.ecs_abnormal_stop
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop-log"
  rule      = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop"
  arn       = aws_cloudwatch_log_group.ecs_abnormal_stop.arn

}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_notification" {
  depends_on     = [
    aws_cloudwatch_event_rule.ecs_abnormal_stop,
    aws_cloudwatch_log_group.ecs_abnormal_stop
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop-notification"
  rule      = "${local.PJPrefix}-${local.EnvPrefix}-ecs-flask-abnormal-stop"
  arn       = aws_sns_topic.slack.arn
  role_arn  = aws_iam_role.eventbridge_rule_sns_target.arn

}
*/
## ------------------------------------------------------------#
##  rds instance abnormal operation detection
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "rds_instance_abnormal_operation" {
  name = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation"
}

resource "aws_cloudwatch_event_rule" "rds_instance_abnormal_operation" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.rds"
    ],
    "resources": ["${aws_rds_cluster_instance.this.arn}"],
    "detail.EventID": [
      "RDS-EVENT-0003",
      "RDS-EVENT-0006",
      "RDS-EVENT-0087",
      "RDS-EVENT-0088",
      "RDS-EVENT-0178"
    ]
  }
  EOT
  # "RDS-EVENT-0003", DBインスタンスの削除検知
  # "RDS-EVENT-0006", DBインスタンスの再起動検知
  # "RDS-EVENT-0087", DBインスタンスの停止検知
  # "RDS-EVENT-0088", DBインスタンスの開始検知
  # "RDS-EVENT-0178"  DBインスタンスのバージョンアップグレード検知

  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "rds_instance_abnormal_operation_log" {
  depends_on     = [
    aws_cloudwatch_event_rule.rds_instance_abnormal_operation,
    aws_cloudwatch_log_group.rds_instance_abnormal_operation
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation-log"
  rule      = "${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation"
  arn       = aws_cloudwatch_log_group.rds_instance_abnormal_operation.arn

}

resource "aws_cloudwatch_event_target" "rds_instance_abnormal_operation_notification" {
  depends_on     = [
    aws_cloudwatch_event_rule.rds_instance_abnormal_operation,
    aws_cloudwatch_log_group.rds_instance_abnormal_operation
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation-notification"
  rule     = "${local.PJPrefix}-${local.EnvPrefix}-rds-instance-abnormal-operation"
  arn      = aws_sns_topic.slack.arn
  role_arn = aws_iam_role.eventbridge_rule_sns_target.arn

}
*/
## ------------------------------------------------------------#
##  rds cluster abnormal operation detection
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "rds_cluster_abnormal_operation" {
  name = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation"

}

resource "aws_cloudwatch_event_rule" "rds_cluster_abnormal_operation" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.rds"
    ],
    "resources": ["${aws_rds_cluster.this.arn}"],
    "detail.EventID": [
      "RDS-EVENT-0150", 
      "RDS-EVENT-0151", 
      "RDS-EVENT-0171", 
      "RDS-EVENT-0173"
    ]
  }
  EOT
  # "RDS-EVENT-0150", DBクラスターの停止検知
  # "RDS-EVENT-0151", DBクラスターの開始検知
  # "RDS-EVENT-0171", DBクラスターの削除検知
  # "RDS-EVENT-0173"  DBクラスターのバージョンアップグレード検知
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "rds_cluster_abnormal_operation_log" {
  depends_on     = [
    aws_cloudwatch_event_rule.rds_cluster_abnormal_operation,
    aws_cloudwatch_log_group.rds_cluster_abnormal_operation
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation-log"
  rule      = "${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation"
  arn       = aws_cloudwatch_log_group.rds_cluster_abnormal_operation.arn

}

resource "aws_cloudwatch_event_target" "rds_cluster_abnormal_operation_notification" {
  depends_on     = [
    aws_cloudwatch_event_rule.rds_cluster_abnormal_operation,
    aws_cloudwatch_log_group.rds_cluster_abnormal_operation
  ]
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation-notification"
  rule      = "${local.PJPrefix}-${local.EnvPrefix}-rds-cluster-abnormal-operation"
  arn       = aws_sns_topic.slack.arn
  role_arn  = aws_iam_role.eventbridge_rule_sns_target.arn

}
*/
# ------------------------------------------------------------#
#  ecs scheduled task 
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs scheduled task rule
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-ecs-scheduled-task"
  schedule_expression = "cron(13 2 ? * SUN *)"
  state               = "ENABLED"
}


resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-scheduled-task"
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
      security_groups  = [aws_security_group.private.id]
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