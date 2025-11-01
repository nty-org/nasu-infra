# ------------------------------------------------------------#
#  cmk
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  cloudtrail
## ------------------------------------------------------------#
/*
resource "aws_kms_key" "cloudtrail" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = false
  enable_key_rotation      = true
  is_enabled               = true
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${local.PJPrefix}/${local.EnvPrefix}/cloudtrail"
  target_key_id = aws_kms_key.cloudtrail.id
}

resource "aws_kms_key_policy" "cloudtrail" {
  key_id = aws_kms_key.cloudtrail.id
  policy = data.aws_iam_policy_document.kms_cloudtrail.json
}

data "aws_iam_policy_document" "kms_cloudtrail" {

  statement {
    sid       = "Enable IAM user permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

  }

  statement {
    sid       = "Allow CloudTrail to encrypt logs"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    #${local.PJPrefix}-${local.EnvPrefix}-management-event と
    #${local.PJPrefix}-${local.EnvPrefix}-s3 証跡へ権限を許可
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:ap-northeast-1:${local.account_id}:trail/${local.PJPrefix}-${local.EnvPrefix}-management-event", "arn:aws:cloudtrail:ap-northeast-1:${local.account_id}:trail/${local.PJPrefix}-${local.EnvPrefix}-s3"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.account_id}:trail/*"]
    }

  }

  statement {
    sid       = "Allow CloudTrail to describe key"
    actions   = ["kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.account_id}:trail/*"]
    }

  }

  statement {
    sid = "Allow alias creation during setup"
    actions = [
      "kms:CreateAlias"
    ]
    resources = [aws_kms_key.cloudtrail.arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.ap-northeast-1.amazonaws.com"]
    }

  }

  statement {
    sid = "Enable cross account log decryption"
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.account_id}:trail/*"]
    }

  }

}
*/