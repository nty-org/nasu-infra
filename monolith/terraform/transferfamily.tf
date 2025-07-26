# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#
## ------------------------------------------------------------#
##  transfer family web app
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "transfer_family_web_app" {
  assume_role_policy    = data.aws_iam_policy_document.transfer_family_web_app_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-transfer-family-web-app-role"
  path                  = "/"

}

data "aws_iam_policy_document" "transfer_family_web_app_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:SetContext"
    ]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

  }
}

resource "aws_iam_policy" "transfer_family_web_app" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-transfer-family-web-app-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.transfer_family_web_app.json

}

data "aws_iam_policy_document" "transfer_family_web_app" {
  statement {
    effect = "Allow"
    actions = [
        "s3:GetDataAccess",
        "s3:ListCallerAccessGrants"
    ]
    resources = [
      "arn:aws:s3:ap-northeast-1:${local.account_id}:access-grants/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }

  }

  statement {
    effect = "Allow"
    actions = [
        "s3:ListAccessGrantsInstances"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }

  }

}

resource "aws_iam_role_policy_attachment" "transfer_family_web_app" {
  role       = aws_iam_role.transfer_family_web_app.name
  policy_arn = aws_iam_policy.transfer_family_web_app.arn
}
*/