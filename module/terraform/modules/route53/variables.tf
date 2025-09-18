# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "app_name" { type = string }

# ------------------------------------------------------------#
#  route53
# ------------------------------------------------------------#

variable "zone_name" { type = string }
variable "dns_name" { type = string }
variable "zone_id" { type = string }
