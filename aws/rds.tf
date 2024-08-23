# ------------------------------------------------------------#
#  common 
# ------------------------------------------------------------#

resource "aws_db_subnet_group" "this" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-subnet"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}

# ------------------------------------------------------------#
#  postgres 
# ------------------------------------------------------------#
/*
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.PJPrefix}-${local.EnvPrefix}-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "14.9"

  availability_zones     = values(data.aws_subnet.private).*.availability_zone
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [data.aws_security_group.private.id]
  manage_master_user_password = true

  master_username   = "postgres"
  port              = "5432"
  storage_encrypted = true

  backup_retention_period = 7
  skip_final_snapshot     = true
  copy_tags_to_snapshot   = true

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

  lifecycle {
    ignore_changes = [
      master_password,
      database_name,
      tags,
    ]
  }
}

resource "aws_rds_cluster_instance" "this" {
  identifier         = "${local.PJPrefix}-${local.EnvPrefix}"
  cluster_identifier = aws_rds_cluster.this.id

  instance_class          = "db.t3.medium"
  engine                  = aws_rds_cluster.this.engine
  engine_version          = aws_rds_cluster.this.engine_version
  db_subnet_group_name    = aws_db_subnet_group.this.name
  promotion_tier          = 1

  auto_minor_version_upgrade = true

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
*/
#nnTCoOZ54GGHAmpf

#zt2Lx7OqotO8PA51

# ------------------------------------------------------------#
#  postgres serverless
# ------------------------------------------------------------#
/*
resource "aws_db_subnet_group" "this" {
  name       = "${local.PJPrefix}-${local.EnvPrefix}-subnets"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }

}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${local.PJPrefix}-${local.EnvPrefix}-db-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "15.3"
  #engine_mode        = "provisioned"

  availability_zones     = values(data.aws_subnet.private).*.availability_zone
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [data.aws_security_group.private.id]


  database_name     = "emomildb"
  master_username   = "postgres"
  master_password   = "Fa7zQX9euAOsCQXz"
  port              = "5432"
  

  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.default.id
  #backup_retention_period             = 1
  storage_encrypted                   = true
  deletion_protection                 = true
  skip_final_snapshot                 = true
  copy_tags_to_snapshot   = true
  #iam_database_authentication_enabled = false

  enabled_cloudwatch_logs_exports     = ["postgresql"]

  serverlessv2_scaling_configuration {
    max_capacity = 32
    min_capacity = 0.5
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }


  lifecycle {
    ignore_changes = [
      master_password,
      database_name,
    ]
  }

}


resource "aws_rds_cluster_instance" "this" {
  identifier         = "${local.PJPrefix}-${local.EnvPrefix}-db-instance"
  cluster_identifier = aws_rds_cluster.this.id


  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
  #db_parameter_group_name = "default.aurora-postgresql14"


  #publicly_accessible = false
  auto_minor_version_upgrade = false
  promotion_tier             = 1 #フェイルオーバー優先順位
}
*/