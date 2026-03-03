# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs exec start
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ecs_exec_start" {
  name              = "/aws/events/${var.pj_prefix}-${var.env_prefix}-ecs-exec-start"
  retention_in_days = var.log_retention_in_days
  
}

## ------------------------------------------------------------#
##  ecs exec stop
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ecs_exec_stop" {
  name              = "/aws/events/${var.pj_prefix}-${var.env_prefix}-ecs-exec-stop"
  retention_in_days = var.log_retention_in_days
  
}