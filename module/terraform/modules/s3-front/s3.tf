# ------------------------------------------------------------#
#  bucket
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  front
## ------------------------------------------------------------#

resource "aws_s3_bucket" "front" {
  for_each = var.s3_buckets

  bucket = each.value.bucket_name
}

resource "aws_s3_bucket_versioning" "front" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.front[each.key].id
  versioning_configuration {
    status = each.value.versioning_status
  }
}

resource "aws_s3_bucket_public_access_block" "front" {
  for_each = var.s3_buckets

  bucket                  = aws_s3_bucket.front[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "front" {
  for_each = var.s3_buckets

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.front[each.key].arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.front.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "front" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.front[each.key].id
  policy = data.aws_iam_policy_document.front[each.key].json
}

resource "aws_s3_bucket_cors_configuration" "front" {
  for_each = var.s3_buckets

  bucket                = aws_s3_bucket.front[each.key].id
  expected_bucket_owner = var.account_id

  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["${each.value.cors_allowed_origins}"]
    expose_headers  = []
  }
}