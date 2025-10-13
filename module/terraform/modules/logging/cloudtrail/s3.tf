# ------------------------------------------------------------#
#  bucket
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  cloudtrail log
## ------------------------------------------------------------#

resource "aws_s3_bucket" "cloudtrail_log" {
  bucket = "${var.pj_prefix}-${var.env_prefix}-cloudtrail-log"
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_log" {
  bucket                  = aws_s3_bucket.cloudtrail_log.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudtrail_log" {

  #s3証跡用ポリシー
  statement {
    sid     = "${var.pj_prefix}-${var.env_prefix}-s3-cloudtrail-acl-check"
    actions = ["s3:GetBucketAcl"]
    resources = [
      "${aws_s3_bucket.cloudtrail_log.arn}"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:ap-northeast-1:${var.account_id}:trail/${var.pj_prefix}-${var.env_prefix}-s3"]
    }

  }

  statement {
    sid     = "${var.pj_prefix}-${var.env_prefix}-s3-cloudtrail-write"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cloudtrail_log.arn}/*/AWSLogs/${var.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:ap-northeast-1:${var.account_id}:trail/${var.pj_prefix}-${var.env_prefix}-s3"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  #管理イベント用ポリシー
  statement {
    sid     = "${var.pj_prefix}-${var.env_prefix}-management-event-cloudtrail-acl-check"
    actions = ["s3:GetBucketAcl"]
    resources = [
      "${aws_s3_bucket.cloudtrail_log.arn}"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:ap-northeast-1:${var.account_id}:trail/${var.pj_prefix}-${var.env_prefix}-management-event"]
    }

  }

  statement {
    sid     = "${var.pj_prefix}-${var.env_prefix}-management-event-cloudtrail-write"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cloudtrail_log.arn}/*/AWSLogs/${var.account_id}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:ap-northeast-1:${var.account_id}:trail/${var.pj_prefix}-${var.env_prefix}-management-event"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

}

resource "aws_s3_bucket_policy" "cloudtrail_log" {
  bucket = aws_s3_bucket.cloudtrail_log.id
  policy = data.aws_iam_policy_document.cloudtrail_log.json

}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_log_management_event" {

  bucket = aws_s3_bucket.cloudtrail_log.id

  rule {
    id = "${var.pj_prefix}-${var.env_prefix}-cloudtrail-log-management-event-lc-rule"

    filter {
      prefix = "management-event/"
    }

    expiration {
      days = var.cloudtrail_bucket_log_retention_in_days
    }

    status = "Enabled"
  }

}