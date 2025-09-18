# ------------------------------------------------------------#
#  cluster
# ------------------------------------------------------------#

resource "aws_ecs_cluster" "this" {
  name = "${var.pj_prefix}-${var.env_prefix}-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_session_manager.name
      }
    }
  }
}
