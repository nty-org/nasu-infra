# ------------------------------------------------------------#
#  distribution
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  front
## ------------------------------------------------------------#

resource "aws_cloudfront_distribution" "front" {
  depends_on = [
    aws_s3_bucket.front
  ]
  
  dynamic "origin" {
    for_each = var.origins

    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      connection_attempts      = 3
      connection_timeout       = 10
      origin_access_control_id = aws_cloudfront_origin_access_control.front.id
      origin_path              = origin.value.origin_path
    }
  }

  default_cache_behavior {
    target_origin_id           = var.default_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = aws_cloudfront_cache_policy.front.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.front.id
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern           = each.value.path_pattern
      allowed_methods        = each.value.allowed_methods
      cached_methods         = each.value.cached_methods
      target_origin_id       = each.value.target_origin_id
      cache_policy_id        = aws_cloudfront_cache_policy.front.id
      compress               = each.value.compress
      viewer_protocol_policy = each.value.viewer_protocol_policy
    }
  }

  enabled             = "true"
  http_version        = "http2"
  is_ipv6_enabled     = "true"
  comment             = "Distribution for Front"
  default_root_object = ""
  aliases             = ["${var.app_name}.${var.zone_name}"]
  # web_acl_id          = aws_wafv2_web_acl.this.arn
  price_class         = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = var.response_page_path
  }

  tags = {
    Service = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}"
  }
}


resource "aws_cloudfront_origin_access_control" "front" {
  name                              = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-origin-access-control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "front" {
  comment     = ""
  default_ttl = "10"
  max_ttl     = "10"
  min_ttl     = "10"
  name        = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-cache-policy"

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    enable_accept_encoding_brotli = "true"
    enable_accept_encoding_gzip   = "true"

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["Origin"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "front" {
  name = "${var.pj_prefix}-${var.env_prefix}-${var.app_name}-response-headers-policy"

  custom_headers_config {
    items {
      header   = "Cache-Control"
      override = false
      value    = "no-cache, no-store, must-revalidate"
    }
  }
}
