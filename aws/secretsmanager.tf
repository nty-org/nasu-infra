# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

resource "aws_secretsmanager_secret" "sync" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/sync"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}

/*
resource "aws_secretsmanager_secret_version" "sync" {
  secret_id = aws_secretsmanager_secret.sync.id
  secret_string = jsonencode({
    "AUTH0_DOMAIN"     = "test"
  })
}
*/

# ------------------------------------------------------------#
#  sync-escape
# ------------------------------------------------------------#

resource "aws_secretsmanager_secret" "sync_escape" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/sync-escape"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}


# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_secretsmanager_secret" "web" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/web"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}


resource "aws_secretsmanager_secret_version" "web" {
  secret_id = aws_secretsmanager_secret.web.id
  secret_string = jsonencode({
    "AUTH0_DOMAIN"     = data.sops_file.secrets_monitoring.data["AUTH0_DOMAIN"],
    "LOG_DIR_PATH"     = data.sops_file.secrets_monitoring.data["LOG_DIR_PATH"],
    "PORT"             = data.sops_file.secrets_monitoring.data["PORT"],
    "REDIS_HOST"       = data.sops_file.secrets_monitoring.data["REDIS_HOST"],
    "REDIS_KEY_PREFIX" = data.sops_file.secrets_monitoring.data["REDIS_KEY_PREFIX"],
    "REDIS_PORT"       = data.sops_file.secrets_monitoring.data["REDIS_PORT"],
    "REDIS_URL"        = data.sops_file.secrets_monitoring.data["REDIS_URL"],
    "SYNC_AUTH_KEY"    = data.sops_file.secrets_monitoring.data["SYNC_AUTH_KEY"],
    "THREADS"          = data.sops_file.secrets_monitoring.data["THREADS"]    
  })
}
*/