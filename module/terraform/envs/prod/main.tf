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