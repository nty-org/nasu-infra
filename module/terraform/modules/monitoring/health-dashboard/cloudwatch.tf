# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  health dashboard
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "health_dashboard" {
  name              = "/aws/events/${var.pj_prefix}-${var.env_prefix}-health-dashboard"
  retention_in_days = 30

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-health-dashboard"
  }
}