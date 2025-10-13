# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  cloud trail
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "cloudtrail_s3" {
  name              = "/cloudtrail/${var.pj_prefix}-${var.env_prefix}-s3"
  retention_in_days = var.cloudwatch_log_retention_in_days

}

resource "aws_cloudwatch_log_group" "cloudtrail_management_event" {
  name              = "/cloudtrail/${var.pj_prefix}-${var.env_prefix}-management-event"
  retention_in_days = var.cloudwatch_log_retention_in_days

}

