# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }

# ------------------------------------------------------------#
#  ec2
# ------------------------------------------------------------#

variable "private_security_group_id" { type = string }
variable "subnet_id" { type = string }

variable "volume_size" { type = number }
variable "volume_type" { type = string  }