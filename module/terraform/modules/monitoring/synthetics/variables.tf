# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# ------------------------------------------------------------#
#  synthetics
# ------------------------------------------------------------#

variable "synthetics_canaries" {
  description = "Synthetics Canaries configuration"
  type = map(object({
    hostname = string
    path     = string
    success_retention_period = number
    failure_retention_period = number
    timeout_in_seconds       = number
    schedule_expression      = string
  }))
}

# ------------------------------------------------------------#
#  cloudwatch
# ------------------------------------------------------------#

variable "sns_topic_slack_arn" {
  description = "SNS Topic ARN for Slack notifications"
  type        = string
}
