# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  synthetics
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "synthetics" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-role"
  assume_role_policy = data.aws_iam_policy_document.synthetics_assume_role_policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"

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

resource "aws_iam_policy" "synthetics" {
  name        = "${local.PJPrefix}-${local.EnvPrefix}-synthetics-policy"
  policy      = data.aws_iam_policy_document.synthetics.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"

}

data "aws_iam_policy_document" "synthetics" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      aws_s3_bucket.synthetics.arn,
      "${aws_s3_bucket.synthetics.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/aws/lambda/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
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

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.synthetics.name
  policy_arn = aws_iam_policy.synthetics.arn
}

resource "aws_iam_role_policy_attachment" "synthetics_lambda_vpc_acccess" {
  role       = aws_iam_role.synthetics.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
*/
# ------------------------------------------------------------#
#  synthetics
# ------------------------------------------------------------#

# ------------------------------------------------------------#
#  api
# ------------------------------------------------------------#
/*
data "archive_file" "synthetics_api" {
  type        = "zip"
  output_path = "${path.module}/canary_script/api/${local.zip_file_api}"

  source {
    content  = local.rendered_file_api
    filename = "nodejs/node_modules/canary_api.js"
  }

}

resource "aws_synthetics_canary" "api" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-api"
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics.id}/api/"
  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_S3"
    }
  }

  execution_role_arn = aws_iam_role.synthetics.arn
  runtime_version    = "syn-nodejs-puppeteer-9.0"
  handler            = "canary_api.handler"
  zip_file           = data.archive_file.synthetics_api.output_path
  start_canary       = true

  success_retention_period = 5
  failure_retention_period = 5

  schedule {
    expression          = "rate(10 minutes)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 60
    active_tracing     = true
  }

  depends_on = [
    data.archive_file.synthetics_api,
  ]
}

# ------------------------------------------------------------#
#  sync
# ------------------------------------------------------------#

data "archive_file" "synthetics_sync" {
  type        = "zip"
  output_path = "${path.module}/canary_script/sync/${local.zip_file_sync}"

  source {
    content  = local.rendered_file_sync
    filename = "nodejs/node_modules/canary_sync.js"
  }

}

resource "aws_synthetics_canary" "sync" {
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-sync"
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics.id}/sync/"
  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_S3"
    }
  }

  execution_role_arn = aws_iam_role.synthetics.arn
  runtime_version    = "syn-nodejs-puppeteer-9.0"
  handler            = "canary_sync.handler"
  zip_file           = data.archive_file.synthetics_sync.output_path
  start_canary       = true

  success_retention_period = 5
  failure_retention_period = 5

  schedule {
    expression          = "rate(10 minutes)"
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = 60
    active_tracing     = true
  }

  depends_on = [
    data.archive_file.synthetics_sync,
  ]
}
*/