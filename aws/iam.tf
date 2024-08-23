# ------------------------------------------------------------#
#  s3 yomel User
# ------------------------------------------------------------#

resource "aws_iam_user" "s3" {
  force_destroy = "false"
  name          = "${local.PJPrefix}-${local.EnvPrefix}-app"
  path          = "/"
}

resource "aws_iam_user_policy_attachment" "s3" {
  policy_arn = aws_iam_policy.s3.arn
  user       = aws_iam_user.s3.name

}

resource "aws_iam_policy" "s3" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-s3"
  path   = "/"
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "s3:PutAccountPublicAccessBlock",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "VisualEditor1"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user_policy_attachment" "bedrock" {
  user       = aws_iam_user.s3.name
  policy_arn = aws_iam_policy.bedrock.arn

}

resource "aws_iam_policy" "bedrock" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-bedrock"
  path   = "/"
  policy = data.aws_iam_policy_document.bedrock.json
}

data "aws_iam_policy_document" "bedrock" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = ["*"]
  }
}