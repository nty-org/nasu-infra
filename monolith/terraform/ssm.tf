# ------------------------------------------------------------#
#  parameter store
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  common
## ------------------------------------------------------------#

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

## ------------------------------------------------------------#
##  app
## ------------------------------------------------------------#

resource "aws_ssm_parameter" "app_container_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/CONTAINER_NAME"
  type  = "String"
  value = "app"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
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

resource "aws_ssm_parameter" "secret_key_name_app" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/SECRET_KEY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/app"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
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

resource "aws_ssm_parameter" "image_repository_name_app" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/IMAGE_REPOSITORY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/app"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}

resource "aws_ssm_parameter" "network_config_app" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/NETWORK_CONFIG"
  type  = "String"
  value = "awsvpcConfiguration={subnets=[${aws_subnet.private["ap-northeast-1a"].id},${aws_subnet.private["ap-northeast-1c"].id},${aws_subnet.private["ap-northeast-1d"].id}],securityGroups=[${aws_security_group.private.id}],assignPublicIp=ENABLED}"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}

resource "aws_ssm_parameter" "cluster_name" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/CLUSTER_NAME"
  type  = "String"
  value = "${local.PJPrefix}-${local.EnvPrefix}-cluster"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}
/*
resource "aws_ssm_parameter" "taskdef_name_migrate" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/app/TASKDEF_NAME_MIGRATE"
  type  = "String"
  value = aws_ecs_task_definition.migrate.id

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-app"
  }
}
*/

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

## ------------------------------------------------------------#
##  api
## ------------------------------------------------------------#

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

resource "aws_ssm_parameter" "secret_key_name_api" {
  name  = "/${local.PJPrefix}/${local.EnvPrefix}/api/SECRET_KEY_NAME"
  type  = "String"
  value = "${local.PJPrefix}/${local.EnvPrefix}/api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

# ------------------------------------------------------------#
#  document
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  session manager log
# ------------------------------------------------------------#

resource "aws_ssm_document" "ssm_log" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "s3BucketName": "${local.PJPrefix}-${local.EnvPrefix}-ssm-log",
        "s3EncryptionEnabled": true,
        "cloudWatchEncryptionEnabled": false,
        "cloudWatchLogGroupName": "/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log",
        "cloudWatchStreamingEnabled": true,
        "idleSessionTimeout": "20"
    }
}
DOC
}

resource "aws_cloudwatch_log_group" "session_manager_log" {
  name = "/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log"
}

resource "aws_cloudwatch_log_metric_filter" "session_manager_rds_acceess" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-session-manager-rds-access"
  pattern        = "{ $.sessionData[0] = *psql* }"
  log_group_name = "/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-session-manager-rds-access"
    namespace = "SSM/"
    value     = 1
  }

}