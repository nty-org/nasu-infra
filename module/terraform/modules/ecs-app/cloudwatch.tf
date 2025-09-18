# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${var.pj_prefix}-${var.env_prefix}-${var.app_name}"

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }
}
