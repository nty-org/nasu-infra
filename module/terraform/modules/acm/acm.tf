# ------------------------------------------------------------#
#  acm
# ------------------------------------------------------------#

resource "aws_acm_certificate" "app" {
  domain_name       = "${var.app_name}.${var.zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}