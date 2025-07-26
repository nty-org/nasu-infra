# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#

resource "aws_route53_zone" "this" {
  name    = local.zone_name
  comment = ""

  lifecycle {
    ignore_changes = [
      force_destroy,
    ]
  }
}

data "aws_route53_zone" "this" {
  name = local.zone_name
}

# ------------------------------------------------------------#
#  code_server
# ------------------------------------------------------------#

resource "aws_route53_record" "code_server_alias" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "code-server.${local.zone_name}"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.code_server.dns_name}"
    zone_id                = aws_lb.code_server.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "acm_validation_code_server" {
  for_each = {
    for dvo in aws_acm_certificate.code_server.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}