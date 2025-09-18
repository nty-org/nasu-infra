# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ecs_session_manager" {
  name = "/ecs/${var.pj_prefix}-${var.env_prefix}-session-manager"
}
