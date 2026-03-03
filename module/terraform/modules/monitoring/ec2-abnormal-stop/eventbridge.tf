# ------------------------------------------------------------#
#  eventbrige rule
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ec2 abnormal stop detection
## ------------------------------------------------------------#

resource "aws_cloudwatch_event_rule" "ec2_abnormal_stop" {
  for_each = var.ec2_instances
  
  name          = "${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-abnormal-stop"
  event_pattern = <<-EOT
  {
    "source": [
      "aws.ec2"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": ["ec2.amazonaws.com"],
      "eventName": ["RebootInstances", "StopInstances"],
      "requestParameters": {
        "instancesSet": {
          "items": {
            "instanceId": ["${data.aws_instance.ec2_instance[each.key].id}"]
          }
        }
      }
    }
  }
  EOT
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "ec2_abnormal_stop_log" {
  for_each = var.ec2_instances
  
  target_id = "${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-abnormal-stop-log"
  rule      = aws_cloudwatch_event_rule.ec2_abnormal_stop[each.key].name
  arn       = aws_cloudwatch_log_group.ec2_abnormal_stop[each.key].arn

}

resource "aws_cloudwatch_event_target" "ec2_abnormal_stop_notification" {
  for_each = var.ec2_instances
  
  target_id = "${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-abnormal-stop-notification"
  rule      = aws_cloudwatch_event_rule.ec2_abnormal_stop[each.key].name
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

      # 停止関連情報
      "arn"       = "$.detail.userIdentity.arn"
      
      # EC2リソース情報
      "eventName"       = "$.detail.eventName"
      "instanceId"      = "$.detail.requestParameters.instancesSet.items[0].instanceId"

    }

    input_template = <<EOF
      {
        "version": "1.0",
        "source": "custom",
        "content": {
          "title": ":rotating_light: EC2 <eventName> | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>",
          "textType": "client-markdown",
          "description": "*EC2 <eventName>  | ${var.pj_prefix}-${var.env_prefix} | <region> | Account: <account>*\n\n\n# *Information*\n\n・ *Instance*: ${each.value.instance_name}\n・ *Time*:  <time>\n・ *Account*:  <account>\n・ *ARN*:  <arn>",
          "nextSteps": [
            "*Check logs*: Review CloudWatch Logs at `/aws/events/${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-abnormal-stop`"
          ]
        }, 
        "metadata": {
          "Instance": "${each.value.instance_name}",
          "Environment": "${var.pj_prefix}-${var.env_prefix}",
          "Region": "<region>",
          "Event time": "<time>",
          "Event ID": "<id>"
        }
      }
    EOF
  }
}
