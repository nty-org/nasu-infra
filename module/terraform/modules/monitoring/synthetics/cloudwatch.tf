# ------------------------------------------------------------#
#  alarm
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  synthetics
## ------------------------------------------------------------#

resource "aws_cloudwatch_metric_alarm" "synthetics_success" {
  for_each = var.synthetics_canaries
  
  alarm_name          = "${var.pj_prefix}-${var.env_prefix}-synthetics-${each.key}-success"
  comparison_operator = "LessThanThreshold"
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 100
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${var.pj_prefix}-${var.env_prefix}-${each.key}"
  }
  alarm_actions = [
    var.sns_topic_slack_arn
  ]
  ok_actions = [
    var.sns_topic_slack_arn
  ]

}

resource "aws_cloudwatch_metric_alarm" "synthetics_duration" {
  for_each = var.synthetics_canaries

  alarm_name          = "${var.pj_prefix}-${var.env_prefix}-synthetics-${each.key}-duration"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "Duration"
  namespace           = "CloudWatchSynthetics"
  statistic           = "Sum"
  threshold           = 10000
  period              = 600

  datapoints_to_alarm = 1
  evaluation_periods  = 1

  treat_missing_data = "breaching"

  dimensions = {
    CanaryName = "${var.pj_prefix}-${var.env_prefix}-${each.key}"
  }
  alarm_actions = [
    var.sns_topic_slack_arn
  ]
  ok_actions = [
    var.sns_topic_slack_arn
  ]

}
