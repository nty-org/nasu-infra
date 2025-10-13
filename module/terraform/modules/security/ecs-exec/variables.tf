# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }

# ------------------------------------------------------------#
#  cloudwatch 
# ------------------------------------------------------------#

variable "log_retention_in_days" {
  type    = number
  default = 90
}

# ------------------------------------------------------------#
#  eventbridge
# ------------------------------------------------------------#

variable "eventbridge_rule_sns_target_role_arn" { type = string }
variable "sns_topic_slack_arn" { type = string }
