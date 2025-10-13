# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

##------------------------------------------------------------#
##  cloudtrail
## ------------------------------------------------------------#

resource "aws_iam_role" "cloudtrail" {
  assume_role_policy   = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.pj_prefix}-${var.env_prefix}-cloudtrail-role"
  path                 = "/"

}

data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "cloudtrail" {
  name   = "${var.pj_prefix}-${var.env_prefix}-cloudtrail-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.cloudtrail.json
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:*:log-stream:${var.account_id}_CloudTrail_ap-northeast-1*"
    ]

  }

}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail.arn
}