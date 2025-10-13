# ------------------------------------------------------------#
#  trail
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  s3
## ------------------------------------------------------------#
/*
resource "aws_cloudtrail" "s3" {
  depends_on     = [
    aws_s3_bucket.cloudtrail_log,
    aws_kms_key.cloudtrail
  ]

  name            = "${var.pj_prefix}-${var.env_prefix}-s3"
  s3_bucket_name  = aws_s3_bucket.cloudtrail_log.id
  s3_key_prefix   = "s3"
  kms_key_id      = aws_kms_key.cloudtrail.arn

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
      starts_with = var.s3_bucket_arns
    }

  }
  
}

*/
## ------------------------------------------------------------#
##  management event
## ------------------------------------------------------------#

resource "aws_cloudtrail" "management_event" {
  depends_on = [
    aws_s3_bucket.cloudtrail_log,
    aws_kms_key.cloudtrail
  ]

  name           = "${var.pj_prefix}-${var.env_prefix}-management-event"
  s3_bucket_name = aws_s3_bucket.cloudtrail_log.id
  s3_key_prefix  = "management-event"
  kms_key_id     = aws_kms_key.cloudtrail.arn

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_management_event.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail.arn

  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true

  enable_logging = true

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
      field = "eventSource"
      not_equals = [
        "kms.amazonaws.com",
        "rdsdata.amazonaws.com"
      ]
    }

  }

}