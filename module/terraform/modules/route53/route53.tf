# ------------------------------------------------------------#
#  host zone
# ------------------------------------------------------------#

data "aws_route53_zone" "this" {
  name = var.zone_name
}

# ------------------------------------------------------------#
#  record
# ------------------------------------------------------------#

resource "aws_route53_record" "alias" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.app_name}.${var.zone_name}"
  type    = "A"

  alias {
    name                   = "dualstack.${var.dns_name}"
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}
