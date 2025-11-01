# ------------------------------------------------------------#
#  bucket
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  synthetics
## ------------------------------------------------------------#

resource "aws_s3_bucket" "synthetics" {
  bucket = "${var.pj_prefix}-${var.env_prefix}-synthetics-reports"

  # バケット内のオブジェクトを強制的に削除
  force_destroy = true  
}

resource "aws_s3_bucket_public_access_block" "synthetics" {
  bucket                  = aws_s3_bucket.synthetics.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "synthetics" {
  bucket = aws_s3_bucket.synthetics.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "synthetics" {
  bucket = aws_s3_bucket.synthetics.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "synthetics" {
  bucket = aws_s3_bucket.synthetics.bucket
  rule {
    id = "config"

    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 5
    }


    status = "Enabled"
  }
}
