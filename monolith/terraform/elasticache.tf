# ------------------------------------------------------------#
#  parameter group
# ------------------------------------------------------------#

resource "aws_elasticache_parameter_group" "this" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-redis7-cluster-on"
  family = "redis7"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

# ------------------------------------------------------------#
#  subnet group
# ------------------------------------------------------------#

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-redis-subnet"
  subnet_ids = data.aws_subnets.private.ids
}

# ------------------------------------------------------------#
#  redis
# ------------------------------------------------------------#
/*
resource "aws_elasticache_replication_group" "this" {
  automatic_failover_enabled  = false
  replication_group_id        = "${local.PJPrefix}-${local.EnvPrefix}-redis"
  description                 = " "
  node_type                   = "cache.t3.micro"
  num_cache_clusters          = 1
  parameter_group_name        = "default.redis7"
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.this.name
  security_group_ids          = [data.aws_security_group.private.id]
}

resource "aws_elasticache_user" "default" {
  user_id       = "${local.PJPrefix}-${local.EnvPrefix}-default-user"
  user_name     = "default"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  authentication_mode {
    type = "no-password-required"
  }

  lifecycle {
    ignore_changes = [
      authentication_mode,
    ]
  }
}

resource "aws_elasticache_user_group" "this" {
  engine        = "REDIS"
  user_group_id = "${local.PJPrefix}-${local.EnvPrefix}-redis-user-group"
  user_ids      = [aws_elasticache_user.default.user_id]
}
*/