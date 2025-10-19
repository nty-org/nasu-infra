# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }

# ------------------------------------------------------------#
#  eventbrige scheduler
# ------------------------------------------------------------#

variable "ec2_night_stop_instances" {
  type = map(object({
    instance_name = string
    start_time    = string
    stop_time     = string
  }))
  default = {}
}

variable "ecs_night_stop_cluster" {
  type    = string
  default = ""
}

variable "ecs_night_stop_services" {
  type = map(object({
    service_name = string
    start_time   = string
    stop_time    = string
  }))
  default = {}
}
/*
variable "rds_night_stop_cluster" {
  type = string
}
*/