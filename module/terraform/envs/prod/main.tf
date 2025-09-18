data "aws_caller_identity" "current" {}

# -------------------------------------------------------------#
#  network
# -------------------------------------------------------------#
module "network" {
  source      = "../../modules/network"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = data.aws_caller_identity.current.account_id
  vpc_cidr   = "10.2.0.0/16"
  azs        = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  azs_suffix = ["a", "c", "d"]
  subnets = {
    public  = ["10.2.0.0/20", "10.2.16.0/20", "10.2.32.0/20"]
    private = ["10.2.48.0/20", "10.2.64.0/20", "10.2.80.0/20"]
  }
}

# -------------------------------------------------------------#
#  domain
# -------------------------------------------------------------#

module "api_acm" {
  source = "../../modules/acm"
  zone_name   = local.zone_name
  app_name    = "api"
  route53_ttl = 300
}

# -------------------------------------------------------------#
#  ecs role
# -------------------------------------------------------------#

module "ecs_role" {
  source = "../../modules/ecs-role"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = data.aws_caller_identity.current.account_id
}

# -------------------------------------------------------------#
#  ecs cluster
# -------------------------------------------------------------#

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
}

# -------------------------------------------------------------#
#  sre
# -------------------------------------------------------------#
/*
module "sre_nightstop" {
  source = "../../modules/sre/night-stop"

  PJPrefix = local.PJPrefix
  
  EnvPrefix = local.EnvPrefix

  # 夜間停止対象EC2
  # 0:00~6:00
  ec2_night_stop_instance_0000-0600 = {
    "nat" = data.aws_instance.nat.id
  }
  
  # 夜間停止対象RDS
  # 0:00~6:00
  rds_cluster  = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
  

  # 夜間停止対象ECS
  ecs_night_stop_cluster  = ""
  # 0:00~6:00
  ecs_night_stop_services_0000-0600 = [
    ""
  ]
  # 0:00~5:30
  ecs_night_stop_services_0000-0530 = [
    ""
  ]

}
*/