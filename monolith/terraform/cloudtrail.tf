# ------------------------------------------------------------#
#  cloudtrail role
# ------------------------------------------------------------#

resource "aws_iam_role" "cloudtrail" {
  assume_role_policy    = data.aws_iam_policy_document.cloudtrail_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-cloudtrail-role"
  path                  = "/"

}

data "aws_iam_policy_document" "cloudtrail_assume_role_policy" {
  statement {
    effect  = "Allow"
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
  name   = "${local.PJPrefix}-${local.EnvPrefix}-cloudtrail-policy"
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
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:*:log-stream:${local.account_id}_CloudTrail_ap-northeast-1*"
    ]

  }

}

resource "aws_iam_role_policy_attachment" "cloudtrail" {
  role       = aws_iam_role.cloudtrail.name
  policy_arn = aws_iam_policy.cloudtrail.arn
}

# ------------------------------------------------------------#
#  cloudtrail s3
# ------------------------------------------------------------#
/*
resource "aws_cloudtrail" "s3" {
  depends_on     = [
    aws_s3_bucket.cloudtrail_log,
    aws_kms_key.cloudtrail
  ]

  name                          = "${local.PJPrefix}-${local.EnvPrefix}-s3"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log.id
  s3_key_prefix                 = "s3"
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_s3.arn}:*"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail.arn}"
  
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = false
  
  advanced_event_selector {
    
    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }
    
    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "eventName"
      equals = ["GetObject"]
    }

    field_selector {
      field       = "resources.ARN"
      starts_with = [aws_s3_bucket.ssm_log.arn]
    }

  }
  
}

resource "aws_cloudwatch_log_group" "cloudtrail_s3" {
  name = "/cloudtrail/s3"

}
*/
# ------------------------------------------------------------#
#  cloudtrail management event
# ------------------------------------------------------------#
/*
resource "aws_cloudtrail" "management_event" {
  depends_on     = [
    aws_s3_bucket.cloudtrail_log,
    aws_kms_key.cloudtrail
  ]

  name                          = "${local.PJPrefix}-${local.EnvPrefix}-management-event"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log.id
  s3_key_prefix                 = "management-event"
  kms_key_id                    = aws_kms_key.cloudtrail.arn
  
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_management_event.arn}:*"
  cloud_watch_logs_role_arn  = "${aws_iam_role.cloudtrail.arn}"
  
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  
  enable_logging                = true
  
  advanced_event_selector {
    name = "管理イベントセレクター"
    
    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
    
    field_selector {
      field  = "readOnly"
      equals = ["false"]
    }

    field_selector {
      field      = "eventSource"
      not_equals = [
        "kms.amazonaws.com",
        "rdsdata.amazonaws.com"
      ]
    }

  }
  
}

resource "aws_cloudwatch_log_group" "cloudtrail_management_event" {
  name = "/cloudtrail/${local.PJPrefix}-${local.EnvPrefix}-management-event"

}

resource "aws_cloudwatch_log_metric_filter" "ecs_exec" {

  name           = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec"

  pattern        = "{ ($.eventName = ExecuteCommand) }"
  log_group_name = "/cloudtrail/${local.PJPrefix}-${local.EnvPrefix}-management-event"

  metric_transformation {
    name      = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec"
    namespace = "CloudTrail/"
    value     = 1
  }

}

resource "aws_cloudwatch_metric_alarm" "ecs_exec" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "${local.PJPrefix}-${local.EnvPrefix}-ecs-exec"
  namespace           = "CloudTrail/"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}
*/