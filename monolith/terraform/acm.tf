# ------------------------------------------------------------#
#  code server
# ------------------------------------------------------------#

resource "aws_acm_certificate" "code_server" {
  domain_name       = "code-server.${local.zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
