resource "aws_ecr_repository" "tf-bg-rp05" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "bg-rp05"
}

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
resource "aws_ecr_repository" "api" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/api"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-api"
  }
}
*/
# ------------------------------------------------------------#
#  django
# ------------------------------------------------------------#
/*
resource "aws_ecr_repository" "django" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/django"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-django"
  }
}
*/
/*
# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

resource "aws_ecr_repository" "sync" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/sync"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  }
}

# ------------------------------------------------------------#
#  web
# ------------------------------------------------------------#

resource "aws_ecr_repository" "web" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/web"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}
*/
# ------------------------------------------------------------#
#  updata state
# ------------------------------------------------------------#
/*
resource "aws_ecr_repository" "updata_state" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/updata-state"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-updata-state"
  }
}
*/