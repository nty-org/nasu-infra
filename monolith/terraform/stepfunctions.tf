# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#

resource "aws_iam_role" "stepfunctios" {
  assume_role_policy    = data.aws_iam_policy_document.stepfunctios_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-stepfunctions-role"
  path                  = "/"
}

data "aws_iam_policy_document" "stepfunctios_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "stepfunctios" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-stepfunctions-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.stepfunctios_role_policy.json
}

data "aws_iam_policy_document" "stepfunctios_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "rds:StopDBCluster",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:StopInstances",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "stepfunctios" {
  role       = aws_iam_role.stepfunctios.name
  policy_arn = aws_iam_policy.stepfunctios.arn
}