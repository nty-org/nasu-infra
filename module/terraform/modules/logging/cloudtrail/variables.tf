# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# ------------------------------------------------------------#
#  cloudwatch
# ------------------------------------------------------------#

variable "cloudwatch_log_retention_in_days" {
  type    = number
  default = 30
}

# ------------------------------------------------------------#
# s3
# ------------------------------------------------------------#

variable "cloudtrail_bucket_log_retention_in_days" {
  type    = number
  default = 30
}

# ------------------------------------------------------------#
# cloudtrail
# ------------------------------------------------------------#

variable "s3_bucket_arns" {
  type    = list(string)
  default = []
}