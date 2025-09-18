# ------------------------------------------------------------#
#  host zone
# ------------------------------------------------------------#

data "aws_route53_zone" "this" {
  name = var.zone_name
}

# ------------------------------------------------------------#
#  record
# ------------------------------------------------------------#

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name            = each.value.name
  records         = [each.value.record]
  ttl             = var.route53_ttl
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}
