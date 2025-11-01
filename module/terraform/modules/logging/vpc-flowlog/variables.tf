# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# ------------------------------------------------------------#
#  vpc
# ------------------------------------------------------------#

variable "aws_vpc_id" {
  description = "The ID of the VPC where VPC Flow Logs will be created"
  type        = string
}
