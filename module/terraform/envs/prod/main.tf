data "aws_caller_identity" "current" {}

# -------------------------------------------------------------#
#  network
# -------------------------------------------------------------#
/*
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
*/
# -------------------------------------------------------------#
#  acm
# -------------------------------------------------------------#
/*
module "api_acm" {
  source = "../../modules/acm"
  zone_name   = local.zone_name
  app_name    = "api"
  route53_ttl = 300
}
*/
# -------------------------------------------------------------#
#  ecs role
# -------------------------------------------------------------#
/*
module "ecs_role" {
  source = "../../modules/ecs-role"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = data.aws_caller_identity.current.account_id
}
*/
# -------------------------------------------------------------#
#  ecs cluster
# -------------------------------------------------------------#

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
}

# -------------------------------------------------------------#
#  ecs app
# -------------------------------------------------------------#
/*
module "api_ecs_app" {
  source = "../../modules/ecs-app"
  # common
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  app_name   = "api"
  account_id = data.aws_caller_identity.current.account_id

  # alb
  public_subnet_ids        = module.network.public_subnet_ids
  public_security_group_id = module.network.public_security_group_id
  health_check_path        = "/"
  certificate_arn          = module.api_acm.certificate_arn
  vpc_id                   = module.network.vpc_id

  # ecs
  cluster = module.ecs_cluster.cluster
  private_subnet_ids = module.network.private_subnet_ids
  private_security_group_id = module.network.private_security_group_id

  execution_role_arn = module.ecs_role.execution_role_arn
  task_role_arn      = module.ecs_role.task_role_arn
  container_cpu      = 512
  container_memory   = 1024
  task_cpu           = 512
  task_memory        = 1024
  desired_count      = 1

  # ssm
  server_env = "develop"
}
*/
# -------------------------------------------------------------#
#  route53
# -------------------------------------------------------------#
/*
module "api_route53" {
  source = "../../modules/route53"
  # common
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  app_name   = "api"

  # route53
  zone_name = local.zone_name
  dns_name  = module.api_ecs_app.dns_name
  zone_id   = module.api_ecs_app.zone_id
}
*/
# -------------------------------------------------------------#
# bastion
# -------------------------------------------------------------#
/*
module "bastion" {
  source = "../../modules/bastion"
  
  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix

  # EC2設定
  subnet_id                 = module.network.private_subnet_ids[0] # 必要に応じてインデックスを指定
  private_security_group_id = module.network.private_security_group_id
  volume_size               = 20
  volume_type               = "gp3"
}
*/
# -------------------------------------------------------------#
# notification
# -------------------------------------------------------------#

module "slack" {
  source = "../../modules/notification"
  
  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = local.account_id

  # q developer設定
  slack_channel_name = "times_nasu"
  slack_team_id = "T02KGURL8BG"
  slack_channel_id = "C05H3HTMLSY"

}

# -------------------------------------------------------------#
# logging
# -------------------------------------------------------------#

## -------------------------------------------------------------#
## cloudtrail
## -------------------------------------------------------------#

module "cloudtrail" {
  source = "../../modules/logging/cloudtrail"
  
  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = local.account_id

  # cloudtrail設定
  s3_bucket_arns = [] # S3のARNリストを指定、例: ["arn:aws:s3:::example-bucket"]
  cloudwatch_log_retention_in_days = 30
  cloudtrail_bucket_log_retention_in_days = 30

}

# -------------------------------------------------------------#
# monitoring
# -------------------------------------------------------------#

## -------------------------------------------------------------#
## ecs abnormal stop
## -------------------------------------------------------------#
/*
module "ecs_abnormal_stop" {
  source = "../../modules/monitoring/ecs-abnormal-stop"
  
  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = local.account_id

  # eventbridge設定
  cluster_arn         = module.ecs_cluster.cluster_arn
  sns_topic_slack_arn = module.slack.sns_topic_slack_arn
  eventbridge_rule_sns_target_role_arn = module.slack.eventbridge_rule_sns_target_role_arn
  ecs_services        = ["app"]

}
*/
# -------------------------------------------------------------#
# security
# -------------------------------------------------------------#

## -------------------------------------------------------------#
## ecs exec
## -------------------------------------------------------------#

module "ecs_exec" {
  source = "../../modules/security/ecs-exec"
  
  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix

  # cloudwatch設定
  log_retention_in_days = 30

  # eventbridge設定
  sns_topic_slack_arn = module.slack.sns_topic_slack_arn
  eventbridge_rule_sns_target_role_arn = module.slack.eventbridge_rule_sns_target_role_arn

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