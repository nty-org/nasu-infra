# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

resource "aws_ssm_parameter" "account_id" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/AWS_ACCOUNT_ID"
  type  = "String"
  value = local.account_id
}

resource "aws_ssm_parameter" "server_env" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_ENV"
  type  = "String"
  value = "develop"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

# ------------------------------------------------------------#
#  flask
# ------------------------------------------------------------#

resource "aws_ssm_parameter" "flask_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/CONTAINER_NAME"
  type  = "String"
  value = "flask"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ssm_parameter" "worker_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/worker/CONTAINER_NAME"
  type  = "String"
  value = "worker"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "beat_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/beat/CONTAINER_NAME"
  type  = "String"
  value = "beat"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "celery_enabled" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/CELERY_ENABLED"
  type  = "String"
  value = "false"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "db_migrate" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
  type  = "String"
  value = "false"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "secret_key_name_flask" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/SECRET_KEY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/flask"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ssm_parameter" "server_type" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/SERVER_TYPE"
  type  = "String"
  value = "app"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "image_repository_name_flask" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/IMAGE_REPOSITORY_NAME"
  type  = "String"
  value = "bg-rp05"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ssm_parameter" "network_config_flask" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/NETWORK_CONFIG"
  type  = "String"
  value = "awsvpcConfiguration={subnets=[${aws_subnet.private["ap-northeast-1a"].id},${aws_subnet.private["ap-northeast-1c"].id},${aws_subnet.private["ap-northeast-1d"].id}],securityGroups=[${aws_security_group.private.id}],assignPublicIp=ENABLED}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/CLUSTER_NAME"
  type  = "String"
  value = "${local.PJPrefix}-${local.EnvPrefix}-cluster"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

resource "aws_ssm_parameter" "taskdef_name_migrate" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/flask/TASKDEF_NAME_MIGRATE"
  type  = "String"
  value = aws_ecs_task_definition.migrate.id

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-flask"
  }
}

# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

resource "aws_ssm_parameter" "secret_key_name_sync" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/SECRET_KEY_NAME_SYNC"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/sync"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

resource "aws_ssm_parameter" "image_repository_name_sync" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/sync/IMAGE_REPOSITORY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/sync"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

resource "aws_ssm_parameter" "sync_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/sync/CONTAINER_NAME"
  type  = "String"
  value = "sync"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_ssm_parameter" "secret_key_name_web" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/web/SECRET_KEY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/web"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}

resource "aws_ssm_parameter" "web_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/web/CONTAINER_NAME"
  type  = "String"
  value = "web"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}

resource "aws_ssm_parameter" "image_repository_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/web/IMAGE_REPOSITORY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/web"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}
*/
# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  codebuild
# ------------------------------------------------------------#

resource "aws_ssm_parameter" "api_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/api/CONTAINER_NAME"
  type  = "String"
  value = "api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

resource "aws_ssm_parameter" "image_repository_name_api" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/api/IMAGE_REPOSITORY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}