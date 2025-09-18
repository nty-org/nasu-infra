# ------------------------------------------------------------#
#  parameter store
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  common
## ------------------------------------------------------------#

resource "aws_ssm_parameter" "account_id" {
  name  = "/${var.pj_prefix}/${var.env_prefix}/AWS_ACCOUNT_ID"
  type  = "String"
  value = var.account_id
}

## ------------------------------------------------------------#
##  app
## ------------------------------------------------------------#

resource "aws_ssm_parameter" "server_env" {
  name  = "/${var.pj_prefix}/${var.env_prefix}/SERVER_ENV"
  type  = "String"
  value = var.server_env

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }
}

resource "aws_ssm_parameter" "server_type" {
  name  = "/${var.pj_prefix}/${var.env_prefix}/SERVER_TYPE"
  type  = "String"
  value = "app"

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }
}
