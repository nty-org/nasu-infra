# ------------------------------------------------------------#
#  eventbrige rule
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  health dashboard
## ------------------------------------------------------------#

resource "aws_cloudwatch_event_rule" "health_dashboard" {
  name          = "${var.pj_prefix}-${var.env_prefix}-health-dashboard"
  event_pattern = <<-EOF
  {
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"]%{ if length(var.health_dashboard_services) > 0 },
    "detail": {
      "service": [
  %{ for s in var.health_dashboard_services ~}
        "${s}"%{ if s != var.health_dashboard_services[length(var.health_dashboard_services) - 1] },%{ endif }
  %{ endfor ~}
      ]
    }%{ endif }
  }
  EOF
  state = "ENABLED"
}

resource "aws_cloudwatch_event_target" "health_dashboard_log" {
  target_id = "${var.pj_prefix}-${var.env_prefix}-health-dashboard-log"
  rule      = aws_cloudwatch_event_rule.health_dashboard.name
  arn       = aws_cloudwatch_log_group.health_dashboard.arn

}

resource "aws_cloudwatch_event_target" "health_dashboard_notification" {
  target_id = "${var.pj_prefix}-${var.env_prefix}-health-dashboard-notification"
  rule      = aws_cloudwatch_event_rule.health_dashboard.name
  arn       = var.sns_topic_slack_arn
  role_arn  = var.eventbridge_rule_sns_target_role_arn

}
