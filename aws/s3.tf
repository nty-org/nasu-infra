/*
# ------------------------------------------------------------#
#  flow_log
# ------------------------------------------------------------#

resource "aws_s3_bucket" "vpc-flowlog" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-vpc-flowlog"
}

resource "aws_s3_bucket_public_access_block" "vpc-flowlog" {
  bucket                  = aws_s3_bucket.vpc-flowlog.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "vpc-flowlog" {
  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.vpc-flowlog.arn}/AWSLogs/${local.account_id}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-northeast-1:${local.account_id}:*"]
    }

  }

  statement {
    sid     = "AWSLogDeliveryAclCheck"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.vpc-flowlog.arn}"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-northeast-1:${local.account_id}:*"]
    }

  }
}

resource "aws_s3_bucket_policy" "vpc-flowlog" {
  bucket = aws_s3_bucket.vpc-flowlog.id
  policy = data.aws_iam_policy_document.vpc-flowlog.json
}
*/

# ------------------------------------------------------------#
#  tfstate
# ------------------------------------------------------------#

resource "aws_s3_bucket" "tfstate" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-tfstate"

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {

  depends_on = [aws_s3_bucket_versioning.tfstate]

  bucket = aws_s3_bucket.tfstate.id

  rule {
    id = "${local.PJPrefix}-${local.EnvPrefix}-tfstate-lc-rule"

    filter {}

    noncurrent_version_expiration {
      newer_noncurrent_versions = 10
      noncurrent_days           = 30
    }

    status = "Enabled"
  }
}

# ------------------------------------------------------------#
#  ssm log
# ------------------------------------------------------------#

resource "aws_s3_bucket" "ssm_log" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-ssm-log"

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_public_access_block" "ssm_log" {
  bucket                  = aws_s3_bucket.ssm_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssm_log" {
  bucket = aws_s3_bucket.ssm_log.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------------#
#  access_log
# ------------------------------------------------------------#

resource "aws_s3_bucket" "alb_access_log" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-alb-access-log"
}

resource "aws_s3_bucket_public_access_block" "alb_access_log" {
  bucket                  = aws_s3_bucket.alb_access_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "alb_access_log" {
  statement {
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.alb_access_log.arn}/*",
      "${aws_s3_bucket.alb_access_log.arn}"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::582318560864:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb_access_log" {
  bucket = aws_s3_bucket.alb_access_log.id
  policy = data.aws_iam_policy_document.alb_access_log.json
}

# ------------------------------------------------------------#
#  athena result
# ------------------------------------------------------------#

resource "aws_s3_bucket" "athena_result" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-athna-result"
}

resource "aws_s3_bucket_public_access_block" "athena_result" {
  bucket                  = aws_s3_bucket.athena_result.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}