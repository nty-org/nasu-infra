# ------------------------------------------------------------#
#  eventbrige rule
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs exec start
## ------------------------------------------------------------#

resource "aws_cloudwatch_event_rule" "ecs_exec_start" {
  name                = "${var.pj_prefix}-${var.env_prefix}-ecs-exec-start"
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
  target_id = "${var.pj_prefix}-${var.env_prefix}-ecs-exec-start-notification"
  rule      = aws_cloudwatch_event_rule.ecs_exec_start.name
  arn       = var.sns_topic_slack_arn
  role_arn  = var.eventbridge_rule_sns_target_role_arn

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
          "title": ":rotating_light: ECS Exec Start | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Exec Start | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Environment*:  `${var.pj_prefix}-${var.env_prefix}`\n・ *Time*:  `<time>`\n・ *Account*:  `<account>`\n\n\n# *User Information*\n\n・ *User Name*: `<userName>`\n・ *Arn*: `<arn>`\n\n\n# *Session Information*\n\n・ *Cluster*: `<cluster>`\n・ *Task*: `<task>`\n・ *Container*: `<container>`",
          "nextSteps": [
            "*Verify access*: Confirm that ECS Exec access was appropriate"
          ]
        }, 
        "metadata": {
          "Environment": "${var.pj_prefix}-${var.env_prefix}",
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

resource "aws_cloudwatch_event_rule" "ecs_exec_stop" {
  name                = "${var.pj_prefix}-${var.env_prefix}-ecs-exec-stop"
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
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_exec_stop_notification" {
  target_id = "${var.pj_prefix}-${var.env_prefix}-ecs-exec-stop-notification"
  rule      = aws_cloudwatch_event_rule.ecs_exec_stop.name
  arn       = var.sns_topic_slack_arn
  role_arn  = var.eventbridge_rule_sns_target_role_arn

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
          "title": ":rotating_light: ECS Exec Stop | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Exec Stop | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Environment*:  `${var.pj_prefix}-${var.env_prefix}`\n・ *Time*:  `<time>`\n・ *Account*:  `<account>`\n\n\n# *Log Information*\n\n・ *Log Group Name*: `<logGroupName>`\n・ *Log Stream Name*: `<logStreamName>`",
          "nextSteps": [
            "*Check logs*: Review CloudWatch Logs at `<logGroupName>/<logStreamName>`"
          ]
        }, 
        "metadata": {
          "Environment": "${var.pj_prefix}-${var.env_prefix}",
          "Region": "<region>",
          "Event time": "<time>",
          "Event ID": "<id>"
        }
      }
    EOF
  }

}
