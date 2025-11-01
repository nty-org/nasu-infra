# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs abnormal stop detection
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ecs_abnormal_stop" {
  for_each = toset(var.ecs_services)
  
  name              = "/aws/events/${var.pj_prefix}-${var.env_prefix}-ecs-${each.key}-abnormal-stop"
  retention_in_days = 30

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${each.key}"
  }
}