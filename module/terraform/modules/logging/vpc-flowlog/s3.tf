# ------------------------------------------------------------#
#  bucket
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  vpc flowlog
## ------------------------------------------------------------#

resource "aws_s3_bucket" "vpc_flowlog" {
  bucket = "${var.pj_prefix}-${var.env_prefix}-vpc-flowlog"

  # バケット内のオブジェクトを強制的に削除
  force_destroy = true  
}

resource "aws_s3_bucket_public_access_block" "vpc_flowlog" {
  bucket                  = aws_s3_bucket.vpc_flowlog.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "vpc_flowlog" {
  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.vpc_flowlog.arn}/AWSLogs/${var.account_id}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-northeast-1:${var.account_id}:*"]
    }

  }

  statement {
    sid     = "AWSLogDeliveryAclCheck"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.vpc_flowlog.arn}"
    ]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:logs:ap-northeast-1:${var.account_id}:*"]
    }

  }

}

resource "aws_s3_bucket_policy" "vpc_flowlog" {
  bucket = aws_s3_bucket.vpc_flowlog.id
  policy = data.aws_iam_policy_document.vpc_flowlog.json
}
