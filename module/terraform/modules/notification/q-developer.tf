# ------------------------------------------------------------#
#  client
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  slack
## ------------------------------------------------------------#

resource "aws_chatbot_slack_channel_configuration" "slack" {
  configuration_name    = var.slack_channel_name
  iam_role_arn          = aws_iam_role.q_developer_slack.arn
  slack_channel_id      = var.slack_channel_id
  slack_team_id         = var.slack_team_id
  guardrail_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  sns_topic_arns        = [aws_sns_topic.slack.arn]

}