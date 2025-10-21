# ------------------------------------------------------------#
#  acm
# ------------------------------------------------------------#

resource "aws_acm_certificate" "app" {
  provider = aws.us_east_1

  domain_name       = "${var.app_name}.${var.zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}