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
  providers = {
    aws         = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "web_acm" {
  source = "../../modules/acm"
  zone_name   = local.zone_name
  app_name    = "web"
  route53_ttl = 300
  providers = {
    aws         = aws
    aws.us_east_1 = aws.us_east_1
  }
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
/*
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
}
*/
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
#  s3 front
# -------------------------------------------------------------#
/*
module "web_s3_front" {
  source = "../../modules/s3-front"
  # common
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  app_name   = "web"
  account_id = data.aws_caller_identity.current.account_id
  zone_name  = local.zone_name

  # s3
  s3_buckets = {
    "web" = {
      bucket_name          = "${local.pj_prefix}-${local.env_prefix}-web"
      versioning_status    = "Enabled"
      cors_allowed_origins = "*" # 必要に応じて変更
    }
  }

  # cloudfront
  origins = {
    web = {
      domain_name = "${local.pj_prefix}-${local.env_prefix}-web.my-bucket.s3.ap-northeast-1.amazonaws.com"
      origin_id   = "${local.pj_prefix}-${local.env_prefix}-web"
      origin_path = ""
    }
  }

  ordered_cache_behaviors = {
    behavior1 = {
      path_pattern           = "/test/*"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "{local.pj_prefix}-${local.env_prefix}-web"
      compress               = true
      viewer_protocol_policy = "https-only"
    }
  }

  default_origin_id   = "${local.pj_prefix}-${local.env_prefix}-web"
  acm_certificate_arn = module.web_acm.certificate_arn
  response_page_path  = "/index.html"
}
*/
# -------------------------------------------------------------#
# notification
# -------------------------------------------------------------#
/*
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
*/
# -------------------------------------------------------------#
# logging
# -------------------------------------------------------------#

## -------------------------------------------------------------#
## cloudtrail
## -------------------------------------------------------------#
/*
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
*/
## -------------------------------------------------------------#
## athena
## -------------------------------------------------------------#
/*
module "alb_access_log_athena" {
  source = "../../modules/logging/athena"

  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix

}
*/
## -------------------------------------------------------------#
## vpc flowlog
## -------------------------------------------------------------#
/*
module "vpc_flowlog" {
  source = "../../modules/logging/vpc-flowlog"

  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = local.account_id

  # vpc flowlog設定
  aws_vpc_id = module.network.vpc_id

}
*/
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
## -------------------------------------------------------------#
## synthetics
## -------------------------------------------------------------#
/*
module "synthetics" {
  source = "../../modules/monitoring/synthetics"

  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix
  account_id = local.account_id

  # synthetics設定
  synthetics_canaries = {
    "app" = {
      hostname = "app.${local.zone_name}"
      path     = "/health_check/"
      success_retention_period = 30
      failure_retention_period = 30
      timeout_in_seconds = 10
      schedule_expression = "rate(5 minutes)"
    }
  }

  # cloudwatch設定
  sns_topic_slack_arn = module.slack.sns_topic_slack_arn

}
*/
# -------------------------------------------------------------#
# security
# -------------------------------------------------------------#

## -------------------------------------------------------------#
## ecs exec
## -------------------------------------------------------------#
/*
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
*/
# -------------------------------------------------------------#
#  cost
# -------------------------------------------------------------#

## -------------------------------------------------------------#
##  night stop
## -------------------------------------------------------------#
module "nightstop" {
  source = "../../modules/cost/night-stop"

  # 共通設定
  pj_prefix  = local.pj_prefix
  env_prefix = local.env_prefix

  # eventbridge scheduler設定
  # 夜間停止対象EC2
  ec2_night_stop_instances = {
    "nat" = {
      instance_name = "${local.pj_prefix}-prod-nat"
      start_time  = "00 08" # 分と時をスペースで区切る
      stop_time   = "00 20"
    }
    "code-server" = {
      instance_name = "${local.pj_prefix}-prod-code-server"
      start_time  = "00 08" # 分と時をスペースで区切る
      stop_time   = "00 20"
    }
  }
/*
  # 夜間停止対象ECS
  ecs_night_stop_cluster  = "${local.pj_prefix}-${local.env_prefix}-cluster"
  ecs_night_stop_services = {
    "app" = {
      service_name       = "${local.pj_prefix}-${local.env_prefix}-app-service"
      start_time         = "00 08" # 分と時をスペースで区切る
      stop_time          = "00 20"
      start_desire_count = 1
      stop_desire_count  = 0
    }
  }
*/
/*
  # 夜間停止対象RDS
  rds_night_stop_cluster = "${local.pj_prefix}-${local.env_prefix}-cluster"

*/
}