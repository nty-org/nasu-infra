# ------------------------------------------------------------#
#  app
# ------------------------------------------------------------#
resource "aws_ecr_repository" "app" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/app"
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