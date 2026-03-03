# common
variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }

# network
variable "vpc_id" { type = string }
variable "allowed_cidr_blocks" {
  description = "許可するIPアドレスのリスト"
  type        = list(string)
}