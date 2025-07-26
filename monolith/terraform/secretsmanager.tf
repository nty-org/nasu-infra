# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#

resource "aws_secretsmanager_secret" "api" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/api"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}

# ------------------------------------------------------------#
#  django
# ------------------------------------------------------------#
/*
resource "aws_secretsmanager_secret" "django" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/django"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}
*/
# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#
/*
resource "aws_secretsmanager_secret" "sync" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/sync"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}
*/
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
/*
resource "aws_secretsmanager_secret" "sync_escape" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/sync-escape"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}
*/
# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#
/*
resource "aws_secretsmanager_secret" "web" {
  name                           = "${local.PJPrefix}/${local.EnvPrefix}/web"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 30
}
*/