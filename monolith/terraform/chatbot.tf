# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  slack
## ------------------------------------------------------------#

resource "aws_iam_role" "chatbot_slack" {
  assume_role_policy   = data.aws_iam_policy_document.chatbot_slack_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-chatbot-slack-role"
  path                 = "/service-role/"

}

data "aws_iam_policy_document" "chatbot_slack_assume_role_policy" {
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

resource "aws_iam_policy" "chatbot_slack" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-chatbot-slack-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot_slack.json
}

data "aws_iam_policy_document" "chatbot_slack" {

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

resource "aws_iam_role_policy_attachment" "chatbot_slack" {
  role       = aws_iam_role.chatbot_slack.name
  policy_arn = aws_iam_policy.chatbot_slack.arn
}

resource "aws_iam_role_policy_attachment" "chatbot_slack_AWSResourceExplorerReadOnlyAccess" {
  role       = aws_iam_role.chatbot_slack.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}

# ------------------------------------------------------------#
#  client
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  slack
## ------------------------------------------------------------#
/*
resource "awscc_chatbot_slack_channel_configuration" "slack" {

  configuration_name = local.slack_channel_name

  slack_workspace_id = local.slack_workspace_id
  slack_channel_id   = local.slack_channel_id

  iam_role_arn = aws_iam_role.chatbot_slack.arn

  sns_topic_arns = [aws_sns_topic.slack.arn]

  guardrail_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}
*/