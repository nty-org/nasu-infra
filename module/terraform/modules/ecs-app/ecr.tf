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
  name                 = "${var.pj_prefix}/${var.env_prefix}/${var.app_name}"
}
