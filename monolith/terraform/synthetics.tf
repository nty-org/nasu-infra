/*
resource "aws_s3_bucket" "canaries_reports" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-canaries-reports"
}

resource "aws_s3_bucket_public_access_block" "canaries_reports" {
  bucket                  = aws_s3_bucket.canaries_reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "canaries_reports" {
  bucket = aws_s3_bucket.canaries_reports.id

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "canaries_reports" {
  bucket = aws_s3_bucket.canaries_reports.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "canaries_reports" {
  bucket = aws_s3_bucket.canaries_reports.bucket
  rule {
    id = "config"

    noncurrent_version_expiration {
      noncurrent_days = 5
    }

    status = "Enabled"
  }
}


resource "aws_s3_bucket_policy" "canaries_reports" {
  bucket = aws_s3_bucket.canaries_reports.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "CanariesReportsBucketPolicy"
    Statement = [
      {
        Sid       = "Permissions"
        Effect    = "Allow"
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        }
        Action   = ["s3:*"]
        Resource = ["${aws_s3_bucket.canaries_reports_bucket.arn}/*"]
      },
      {
        "Sid": "AllowSSLRequestsOnly",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
          aws_s3_bucket.canaries_reports_bucket.arn,
          "${aws_s3_bucket.canaries_reports_bucket.arn}/*"
        ],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        },
        "Principal": "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "synthetics_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "synthetics" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-role"
  assume_role_policy = data.aws_iam_policy_document.synthetics_assume_role_policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"

}

resource "aws_iam_role_policy_attachment" "synthetics_AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.synthetics.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "synthetics" {
  statement {
    sid     = "CanaryS3Permission1"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      aws_s3_bucket.canaries_reports.arn,
      "${aws_s3_bucket.canaries_reports.arn}/*"
    ]
  }

  statement {
    sid     = "CanaryS3Permission2"
    effect  = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid     = "CanaryCloudWatchLogs"
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:267751904634:log-group:/aws/lambda/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid     = "CanaryCloudWatchAlarm"
    effect  = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["CloudWatchSynthetics"]
      variable = "cloudwatch:namespace"
    }
  }
}

resource "aws_iam_policy" "synthetics" {
  name        = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-policy"
  policy      = data.aws_iam_policy_document.synthetics.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"

}

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.synthetics.name
  policy_arn = aws_iam_policy.synthetics.arn
}

# ------------------------------------------------------------#
#  synthetics
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#

locals {

  rendered_file_api = templatefile("${path.module}/canary_script/source/nodejs/node_modules/canary_api.js.tpl", {
    name            = "",
    #take_screenshot = var.take_screenshot,
    api_hostname    = "api.stg.yomel.co",
    api_path        = "/health_check/",
    #region          = ap-northeast-1
  })
  
  zip_file_name_api = "canary_api_${sha256(local.rendered_file_api)}.zip"
  // to make sure the canary is redeployed whenever the rendered templated file is modified.

}

data "archive_file" "canary_zip_api" {
  type        = "zip"
  output_path = "${path.module}/canary_script/${local.zip_file_name_api}"

  source {
    content  = local.rendered_file_api
    filename = "nodejs/node_modules/canary_api.js"
  }

}
*/
/*
resource "aws_synthetics_canary" "api" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-api-canary"
  artifact_s3_location = "s3://${aws_s3_bucket.canaries_reports.id}/api/"
  artifact_config {
      s3_encryption {
          encryption_mode = "SSE_S3"
      }
  }
  
  execution_role_arn   = aws_iam_role.synthetics.arn
  runtime_version      = "syn-nodejs-puppeteer-9.0"
  handler              = "canary_api.handler"
  zip_file             = data.archive_file.canary_zip_api.output_path
  start_canary         = true
  
  success_retention_period = 5
  failure_retention_period = 5

  schedule {
    expression          = "rate(10 minutes)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 60
    active_tracing     = true
    #memory_in_mb       = 1000
  }

  depends_on = [
    #data.archive_file.lambda_canary_zip,
  ]
}

resource "aws_cloudwatch_metric_alarm" "synthetics_api_success" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-api-success"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SuccessPercent"
  namespace           = "CloudWatchSynthetics"
  period              = 600
  statistic           = "Sum"
  threshold           = 100
  datapoints_to_alarm = 1
  treat_missing_data  = "breaching"
  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-api-canary"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "synthetics_api_duration" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-api-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "CloudWatchSynthetics"
  period              = 600
  statistic           = "Sum"
  threshold           = 3000
  datapoints_to_alarm = 1
  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-api-canary"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}
*/
/*
# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

locals {

  rendered_file_sync = templatefile("${path.module}/canary_script/source/nodejs/node_modules/canary_api.js.tpl", {
    name            = "",
    #take_screenshot = var.take_screenshot,
    api_hostname    = "sync.stg.yomel.co",
    api_path        = "",
    #region          = ap-northeast-1
  })
  
  zip_file_name_sync = "canary_sync_${sha256(local.rendered_file_sync)}.zip"
  // to make sure the canary is redeployed whenever the rendered templated file is modified.

}

data "archive_file" "canary_zip_sync" {
  type        = "zip"
  output_path = "${path.module}/canary_script/${local.zip_file_name_sync}"

  source {
    content  = local.rendered_file_sync
    filename = "nodejs/node_modules/canary_sync.js"
  }

}

resource "aws_synthetics_canary" "sync" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-sync-canaly"
  artifact_s3_location = "s3://${aws_s3_bucket.canaries_reports.id}/sync/"
  artifact_config {
      s3_encryption {
          encryption_mode = "SSE_S3"
      }
  }
  
  execution_role_arn   = aws_iam_role.synthetics.arn
  runtime_version      = "syn-nodejs-puppeteer-9.0"
  handler              = "canary_sync.handler"
  zip_file             = data.archive_file.canary_zip_sync.output_path
  start_canary         = true
  
  success_retention_period = 5
  failure_retention_period = 5

  schedule {
    expression          = "rate(10 minutes)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 60
    active_tracing     = true
    #memory_in_mb       = 1000
  }

  depends_on = [
    #data.archive_file.lambda_canary_zip,
  ]
}

resource "aws_cloudwatch_metric_alarm" "synthetics_sync" {
  alarm_name          = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-sync"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Failed"
  namespace           = "CloudWatchSynthetics"
  period              = 600
  statistic           = "Sum"
  threshold           = 1
  datapoints_to_alarm = 1
  dimensions = {
    CanaryName = "${local.PJPrefix}-${local.EnvPrefix}-sync-canary"
  }
  alarm_actions = [
    aws_sns_topic.slack.arn
  ]
}
*/