# ------------------------------------------------------------#
#  bucket
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  athena result
## ------------------------------------------------------------#

resource "aws_s3_bucket" "athena_result" {
  bucket = "${var.pj_prefix}-${var.env_prefix}-athena-result"
}

resource "aws_s3_bucket_public_access_block" "athena_result" {
  bucket                  = aws_s3_bucket.athena_result.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_result" {

  bucket = aws_s3_bucket.athena_result.id

  rule {
    id = "${var.pj_prefix}-${var.env_prefix}-athena-result-lc-rule"

    filter {} # filterなし(全オブジェクトに適用)

    expiration {
      days = 1
    }

    status = "Enabled"
  }
}
