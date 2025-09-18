# common
variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }

# network
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "azs_suffix" { type = list(string) }
variable "subnets" { type = map(list(string)) }