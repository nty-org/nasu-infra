output "sns_topic_slack_arn" {
  value = aws_sns_topic.slack.arn
}

output "eventbridge_rule_sns_target_role_arn" {
  value = aws_iam_role.eventbridge_rule_sns_target.arn
}