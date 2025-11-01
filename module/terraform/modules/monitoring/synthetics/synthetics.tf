# ------------------------------------------------------------#
#  synthetics
# ------------------------------------------------------------#

resource "aws_synthetics_canary" "this" {
  for_each = var.synthetics_canaries

  name                 = "${var.pj_prefix}-${var.env_prefix}-${each.key}"
  artifact_s3_location = "s3://${aws_s3_bucket.synthetics.id}/${each.key}"
  artifact_config {
    s3_encryption {
      encryption_mode = "SSE_S3"
    }
  }

  execution_role_arn = aws_iam_role.synthetics.arn
  runtime_version    = "syn-nodejs-puppeteer-9.0"
  handler            = "canary_${each.key}.handler"
  zip_file           = data.archive_file.synthetics[each.key].output_path
  start_canary       = true

  success_retention_period = each.value.success_retention_period
  failure_retention_period = each.value.failure_retention_period

  schedule {
    expression          =  each.value.schedule_expression
    duration_in_seconds = 0
  }

  run_config {
    timeout_in_seconds = each.value.timeout_in_seconds
    active_tracing     = true
  }
}