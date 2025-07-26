# ------------------------------------------------------------#
#  web_vue3
# ------------------------------------------------------------#
/*
resource "aws_cloudfront_distribution" "web_vue3" {
  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.yomel.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cache_control_no_cache.id
    cached_methods             = ["GET", "HEAD"]
    compress                   = "true"
    target_origin_id           = aws_s3_bucket.web_vue3.id
    viewer_protocol_policy     = "redirect-to-https"
  }

   ordered_cache_behavior {
    path_pattern           = "/yomel/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.assets.bucket_regional_domain_name
    cache_policy_id        = aws_cloudfront_cache_policy.yomel.id
    compress               = true
    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern           = "/maintenance/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.assets.bucket_regional_domain_name
    cache_policy_id        = aws_cloudfront_cache_policy.yomel.id
    compress               = true
    viewer_protocol_policy = "https-only"
  }

  enabled             = "true"
  http_version        = "http2"
  is_ipv6_enabled     = "true"
  comment             = "Distribution for Web Vue3"
  default_root_object = ""
  aliases             = ["web.${local.zone_name}"]
  web_acl_id          = aws_wafv2_web_acl.this.arn

  origin {
    connection_attempts      = "3"
    connection_timeout       = "10"
    origin_access_control_id = aws_cloudfront_origin_access_control.web_vue3.id
    origin_id                = aws_s3_bucket.web_vue3.id
    domain_name              = aws_s3_bucket.web_vue3.bucket_regional_domain_name
    origin_path              = "/latest"
  }

  origin {
    connection_attempts      = "3"
    connection_timeout       = "10"
    origin_access_control_id = aws_cloudfront_origin_access_control.web_vue3.id
    origin_id                = aws_s3_bucket.assets.bucket_regional_domain_name
    domain_name              = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_path              = ""
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.web.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-web"
  }
}
*/