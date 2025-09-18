# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }
variable "app_name" { type = string }

# ------------------------------------------------------------#
#  alb
# ------------------------------------------------------------#

variable "public_security_group_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "health_check_path" { type = string }
variable "certificate_arn" { type = string }
variable "vpc_id" { type = string }

# ------------------------------------------------------------#
#  ecs
# ------------------------------------------------------------#

variable "cluster" { type = string }

variable "private_security_group_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

variable "execution_role_arn" { type = string  }
variable "task_role_arn" { type = string  }

variable "container_cpu" { type = number }
variable "container_memory" { type = number }
variable "task_cpu" { type = number }
variable "task_memory" { type = number }
variable "desired_count" { type = number }
/*
variable "min_capacity" { type = number }
variable "max_capacity" { type = number }
variable "up_min_capacity" { type = number }
variable "up_max_capacity" { type = number }
variable "down_min_capacity" { type = number }
variable "down_max_capacity" { type = number }
*/

# ------------------------------------------------------------#
#  ssm
# ------------------------------------------------------------#

variable "server_env" { type = string }