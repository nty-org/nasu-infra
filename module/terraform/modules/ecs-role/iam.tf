# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ecs task role
## ------------------------------------------------------------#

resource "aws_iam_role" "ecs_task" {
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.pj_prefix}-${var.env_prefix}-ecs-task-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:ecs:ap-northeast-1:${var.account_id}:*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }

  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${var.pj_prefix}-${var.env_prefix}-ecs-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task.json

}

data "aws_iam_policy_document" "ecs_task" {

  # secretsmangerからの環境変数取得用権限
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }

  # ecs exec用権限
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = [
      "*"
    ]
  }

  # ecs execログ保存用権限
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

}


resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

## ------------------------------------------------------------#
##  ecs task exec role
## ------------------------------------------------------------#

resource "aws_iam_role" "ecs_task_exec" {
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_exec_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.pj_prefix}-${var.env_prefix}-ecs-task-exec-role"
  path                 = "/service-role/"
}

data "aws_iam_policy_document" "ecs_task_exec_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ecs_task_exec" {
  name   = "${var.pj_prefix}-${var.env_prefix}-ecs-exec-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_task_exec.json

}

data "aws_iam_policy_document" "ecs_task_exec" {

  # ecrからのイメージ取得用権限
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  # ssm secretsmanagerからの値参照用権限
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }

  # cloudwatchへのログ保存用権限
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = aws_iam_policy.ecs_task_exec.arn
}
