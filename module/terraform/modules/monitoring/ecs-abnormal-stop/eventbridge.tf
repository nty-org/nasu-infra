# ------------------------------------------------------------#
#  eventbrige rule
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs abnormal stop detection
## ------------------------------------------------------------#

resource "aws_cloudwatch_event_rule" "ecs_abnormal_stop" {
  for_each = toset(var.ecs_services)
  
  name          = "${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-abnormal-stop"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.ecs"
    ],
    "detail-type": [
      "ECS Task State Change"
    ],
    "detail": {
      "clusterArn": ["${var.cluster_arn}"],
      "$or": [{
        "containers": {
          "exitCode": [{ "anything-but": [ 0, 137, 143 ] }]
        }
      },
      {
        "stoppedReason": [{ "anything-but": { "prefix": "Scaling activity initiated by (deployment ecs-svc" } }]
      }],
      "lastStatus": ["STOPPED"], 
      "taskDefinitionArn" : [{ "prefix": "arn:aws:ecs:ap-northeast-1:${var.account_id}:task-definition/${var.pj_prefix}-${var.env_prefix}-${each.key}-fargate-task"}]
    }
  }
  EOT
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_log" {
  for_each = toset(var.ecs_services)
  
  target_id = "${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-abnormal-stop-log"
  rule      = aws_cloudwatch_event_rule.ecs_abnormal_stop[each.key].name
  arn       = aws_cloudwatch_log_group.ecs_abnormal_stop[each.key].arn

}

resource "aws_cloudwatch_event_target" "ecs_abnormal_stop_notification" {
  for_each = toset(var.ecs_services)
  
  target_id = "${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-abnormal-stop-notification"
  rule      = aws_cloudwatch_event_rule.ecs_abnormal_stop[each.key].name
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
          "title": ":rotating_light: <detailType> | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*ECS Abnormal Stop Detection | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Service*:  ${var.pj_prefix}-${var.env_prefix}-${each.key}-service\n・ *Time*:  <time>\n・ *Account*:  <account>\n\n\n# *Stop Reason*\n\n・ *Stopped Reason*:  <stoppedReason>\n・ *Stopped Code*:  <stoppedCode>\n・ *Exit Code*:  <exitCode>\n\n\n# *Task Information*\n\n・ *Task*: `<taskArn>`\n・ *Task Definition*: `<taskDefinitionArn>`\n・ *Cluster*: `<clusterArn>`",
          "nextSteps": [
            "*Check logs*: Review CloudWatch Logs at `/aws/ecs/${var.pj_prefix}-${var.env_prefix}-${each.key}`",
            "*Memory/CPU*: Verify resource Metrics in CloudWatch Metrics",
            "*Permissions*: Check task execution role and task role permissions at `${var.pj_prefix}-${var.env_prefix}-ecs-task-role`",
            "*Dependent services*: Verify status of related RDS/Redis/OpenSearch and other dependencies"
          ]
        }, 
        "metadata": {
          "Service": "${var.pj_prefix}-${var.env_prefix}-${each.key}-service",
          "Environment": "${var.pj_prefix}-${var.env_prefix}",
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
