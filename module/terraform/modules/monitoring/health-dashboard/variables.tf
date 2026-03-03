# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# ------------------------------------------------------------#
#  eventbridge
# ------------------------------------------------------------#

variable "sns_topic_slack_arn" { type = string }
variable "eventbridge_rule_sns_target_role_arn" { type = string }
variable "health_dashboard_services" {
  description = "List of services to monitor for health dashboard events"
  type    = list(string)
  default = []
}