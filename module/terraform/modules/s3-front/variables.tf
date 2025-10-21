# ------------------------------------------------------------#
#  common
# ------------------------------------------------------------#

variable "pj_prefix" { type = string }
variable "env_prefix" { type = string }
variable "account_id" { type = string }
variable "app_name" { type = string }
variable "zone_name" { type = string }

# ------------------------------------------------------------#
#  s3
# ------------------------------------------------------------#

variable "s3_buckets" {
  description = "CloudFrontで使用するS3バケットのリスト"
  type        = map(object({
    bucket_name           = string
    versioning_status     = string
    cors_allowed_origins  = string
  }))
}

# ------------------------------------------------------------#
#  cloudfront
# ------------------------------------------------------------#

variable "origins" {
  description = "CloudFrontのオリジン情報"
  type        = map(object({
    domain_name = string
    origin_id   = string
    origin_path = string
  }))
}

variable "ordered_cache_behaviors" {
  description = "CloudFrontのordered_cache_behavior情報"
  type = map(object({
    path_pattern           = string
    allowed_methods        = list(string)
    cached_methods         = list(string)
    target_origin_id       = string
    cache_policy_id        = string
    compress               = bool
    viewer_protocol_policy = string
  }))
  default = {}
}

variable "default_origin_id" {
  description = "デフォルトのオリジンID"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM証明書のARN"
  type        = string
}

variable "response_page_path" {
  description = "エラーレスポンスページのパス"
  type        = string
}
