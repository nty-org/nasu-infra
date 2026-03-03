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
variable "ec2_instances" {
  type = map(object({
    instance_name = string
  }))
  default = {}
}