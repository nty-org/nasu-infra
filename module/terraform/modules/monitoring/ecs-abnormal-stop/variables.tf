# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# ------------------------------------------------------------#
#  eventbridge
# ------------------------------------------------------------#

variable "cluster_arn" { type = string }
variable "sns_topic_slack_arn" { type = string }
variable "eventbridge_rule_sns_target_role_arn" { type = string }
variable "ecs_services" {
  description = "List of ECS services to monitor for abnormal stops"
  type        = list(string)
}