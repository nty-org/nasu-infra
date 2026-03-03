# ------------------------------------------------------------#
#  log group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ec2 abnormal stop detection
## ------------------------------------------------------------#

resource "aws_cloudwatch_log_group" "ec2_abnormal_stop" {
  for_each = var.ec2_instances
  
  name              = "/aws/events/${var.pj_prefix}-${var.env_prefix}-ec2-${each.key}-abnormal-stop"
  retention_in_days = 30

  tags = {
    Service = "${each.value.instance_name}"
  }
}