# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  eventbrige scheduler
## ------------------------------------------------------------#
/*
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
*/
## ------------------------------------------------------------#
##  eventbridge rule sns target
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "eventbridge_rule_sns_target" {
  assume_role_policy   = data.aws_iam_policy_document.eventbridge_rule_sns_target_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-eventbridge-rule-sns-target-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "eventbridge_rule_sns_target_assume_role_policy" {
  statement {
    effect = "Allow"
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
/*
resource "aws_scheduler_schedule" "ec2_stop" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-stop"
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
*/
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
  for_each = toset(["app"])
  
  name              = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-ecs-${each.key}-abnormal-stop"
  retention_in_days = 30

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-${each.key}"
  }
}

resource "aws_cloudwatch_event_rule" "ecs_abnormal_stop" {
  for_each = toset(["app"])
  
  name                = "${local.PJPrefix}-${local.EnvPrefix}-ecs-${each.key}-abnormal-stop"
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
          "exitCode": [{ "anything-but": [ 0, 137, 143 ] }]
        }
      },
      {
        "stoppedReason": [{ "anything-but": { "prefix": "Scaling activity initiated by (deployment ecs-svc" } }]
      }],
      "lastStatus": ["STOPPED"], 
      "taskDefinitionArn" : [{ "prefix": "arn:aws:ecs:ap-northeast-1:${local.account_id}:task-definition/${local.PJPrefix}-${local.EnvPrefix}-${each.key}-fargate-task"}]
    }
  }
  EOT
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_log" {
  for_each = toset(["app"])
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-${each.key}-abnormal-stop-log"
  rule      = aws_cloudwatch_event_rule.ecs_abnormal_stop[each.key].name
  arn       = aws_cloudwatch_log_group.ecs_abnormal_stop[each.key].arn

}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_notification" {
  for_each = toset(["app"])
  
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-${each.key}-abnormal-stop-notification"
  rule      = aws_cloudwatch_event_rule.ecs_abnormal_stop[each.key].name
  arn       = aws_sns_topic.slack.arn
  role_arn  = aws_iam_role.eventbridge_rule_sns_target.arn
  
  input_transformer {
    input_paths = {
      # イベント基本情報
      "account"    = "$.account"
      "region"     = "$.region"
      "id"         = "$.id"
      "time"       = "$.time"
      "detailType" = "$.detail-type"
      
      # ECSリソース情報
      "clusterArn"       = "$.detail.clusterArn"
      "taskArn"          = "$.detail.taskArn"
      "taskDefinitionArn" = "$.detail.taskDefinitionArn"
      
      # 停止関連情報
      "stoppedReason" = "$.detail.stoppedReason"
      "stoppedCode"   = "$.detail.stopCode"
      
      # コンテナ情報
      "exitCode"    = "$.detail.containers[0].exitCode"
      "containers"  = "$.detail.containers"
    }

    input_template = <<EOF
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "title": ":rotating_light: <detailType> | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Abnormal Stop Detection | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Service*:  ${local.PJPrefix}-${local.EnvPrefix}-${each.key}-service\n・ *Time*:  <time>\n・ *Account*:  <account>\n\n\n# *Stop Reason*\n\n・ *Stopped Reason*:  <stoppedReason>\n・ *Stopped Code*:  <stoppedCode>\n・ *Exit Code*:  <exitCode>\n\n\n# *Task Information*\n\n・ *Task*: `<taskArn>`\n・ *Task Definition*: `<taskDefinitionArn>`\n・ *Cluster*: `<clusterArn>`",
          "nextSteps": [
            "*Check logs*: Review CloudWatch Logs at `/aws/ecs/${local.PJPrefix}-${local.EnvPrefix}-${each.key}`",
            "*Memory/CPU*: Verify resource Metrics in CloudWatch Metrics",
            "*Permissions*: Check task execution role and task role permissions at `${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role`",
            "*Dependent services*: Verify status of related RDS/Redis/OpenSearch and other dependencies"
          ]
        }, 
        "metadata": {
          "Service": "${local.PJPrefix}-${local.EnvPrefix}-${each.key}-service",
          "Environment": "${local.PJPrefix}-${local.EnvPrefix}",
          "Region": "<region>",
          "Exit code": "<exitCode>",
          "Stop reason": "<stoppedReason>",
          "Stop code": "<stoppedCode>",
          "Event time": "<time>",
          "Event ID": "<id>"
        }
      }
    EOF
  }

}
*/
## ------------------------------------------------------------#
##  ecs exec start
## ------------------------------------------------------------#
/*
resource "aws_cloudwatch_log_group" "ecs_exec_start" {
  name              = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-start"
  retention_in_days = 30
  
}

resource "aws_cloudwatch_event_rule" "ecs_exec_start" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-start"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.ecs"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": ["ecs.amazonaws.com"],
      "eventName": ["ExecuteCommand"]
    }
  }
  EOT
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_exec_start_notification" {
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-start-notification"
  rule      = aws_cloudwatch_event_rule.ecs_exec_start.name
  arn       = aws_sns_topic.slack.arn
  role_arn  = aws_iam_role.eventbridge_rule_sns_target.arn

  input_transformer {
    input_paths = {
      # イベント基本情報
      "account"    = "$.account"
      "region"     = "$.region"
      "id"         = "$.id"
      "time"       = "$.time"
      "detailType" = "$.detail-type"
      
      # ユーザー情報
      "userName" = "$.detail.userIdentity.userName"
      "arn"      = "$.detail.userIdentity.arn"
      
      # セッション情報
      "cluster"   = "$.detail.requestParameters.cluster"
      "container" = "$.detail.requestParameters.container"
      "task"      = "$.detail.requestParameters.task"
      
    }
    
    input_template = <<EOF
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "title": ":rotating_light: ECS Exec Start | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Exec Start | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Environment*:  `${local.PJPrefix}-${local.EnvPrefix}`\n・ *Time*:  `<time>`\n・ *Account*:  `<account>`\n\n\n# *User Information*\n\n・ *User Name*: `<userName>`\n・ *Arn*: `<arn>`\n\n\n# *Session Information*\n\n・ *Cluster*: `<cluster>`\n・ *Task*: `<task>`\n・ *Container*: `<container>`",
          "nextSteps": [
            "*Verify access*: Confirm that ECS Exec access was appropriate"
          ]
        }, 
        "metadata": {
          "Environment": "${local.PJPrefix}-${local.EnvPrefix}",
          "Region": "<region>",
          "Event time": "<time>",
          "Event ID": "<id>"
        }
      }
    EOF
  }
  
}

## ------------------------------------------------------------#
##  ecs exec stop
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ecs_exec_stop" {
  name              = "/aws/events/${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-stop"
  retention_in_days = 30
  
}

resource "aws_cloudwatch_event_rule" "ecs_exec_stop" {
  name                = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-stop"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.logs"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": ["logs.amazonaws.com"],
      "eventName": ["CreateLogStream"],
      "requestParameters": {
        "logStreamName": [{
          "prefix": "ecs-execute-command-"
        }]
      }
    }
  }
  EOT
  state               = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_exec_stop_notification" {
  target_id = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec-stop-notification"
  rule      = aws_cloudwatch_event_rule.ecs_exec_stop.name
  arn       = aws_sns_topic.slack.arn
  role_arn  = aws_iam_role.eventbridge_rule_sns_target.arn

  input_transformer {
    input_paths = {
      # イベント基本情報
      "account"    = "$.account"
      "region"     = "$.region"
      "id"         = "$.id"
      "time"       = "$.time"
      "detailType" = "$.detail-type"
      
      # ログ情報
      "logGroupName"  = "$.detail.requestParameters.logGroupName"
      "logStreamName" = "$.detail.requestParameters.logStreamName"
    }
    
    input_template = <<EOF
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "title": ":rotating_light: ECS Exec Stop | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Exec Stop | ${local.PJPrefix}-${local.EnvPrefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Environment*:  `${local.PJPrefix}-${local.EnvPrefix}`\n・ *Time*:  `<time>`\n・ *Account*:  `<account>`\n\n\n# *Log Information*\n\n・ *Log Group Name*: `<logGroupName>`\n・ *Log Stream Name*: `<logStreamName>`",
          "nextSteps": [
            "*Check logs*: Review CloudWatch Logs at `<logGroupName>/<logStreamName>`"
          ]
        }, 
        "metadata": {
          "Environment": "${local.PJPrefix}-${local.EnvPrefix}",
          "Region": "<region>",
          "Event time": "<time>",
          "Event ID": "<id>"
        }
      }
    EOF
  }

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