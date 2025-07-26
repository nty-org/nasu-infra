# ------------------------------------------------------------#
#  topic
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  slack
## ------------------------------------------------------------#

resource "aws_sns_topic" "slack" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-slack"
}

resource "aws_sns_topic_policy" "slack" {
  arn    = aws_sns_topic.slack.arn
  policy = data.aws_iam_policy_document.sns_slack.json
}

data "aws_iam_policy_document" "sns_slack" {

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        local.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.slack.arn,
    ]

  }
}

resource "aws_sns_topic_subscription" "slack" {
  topic_arn = aws_sns_topic.slack.arn
  protocol  = "https"
  endpoint  = "https://global.sns-api.chatbot.amazonaws.com"
}
