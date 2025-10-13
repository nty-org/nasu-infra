# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  q developer slack
## ------------------------------------------------------------#

resource "aws_iam_role" "q_developer_slack" {
  assume_role_policy   = data.aws_iam_policy_document.q_developer_slack_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.pj_prefix}-${var.env_prefix}-q-developer-slack-role"
  path                 = "/service-role/"

}

data "aws_iam_policy_document" "q_developer_slack_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "q_developer_slack" {
  name   = "${var.pj_prefix}-${var.env_prefix}-q_developer-slack-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.q_developer_slack.json
}

data "aws_iam_policy_document" "q_developer_slack" {

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "q_developer_slack" {
  role       = aws_iam_role.q_developer_slack.name
  policy_arn = aws_iam_policy.q_developer_slack.arn
}

resource "aws_iam_role_policy_attachment" "q_developer_slack_AWSResourceExplorerReadOnlyAccess" {
  role       = aws_iam_role.q_developer_slack.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}