# ------------------------------------------------------------#
#  alb access log
# ------------------------------------------------------------#

resource "aws_athena_workgroup" "alb_access_log" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-alb-access-log"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_result.id}/"
    }
  }
}

resource "aws_athena_database" "alb_access_log" {
  name   = "alb_db"
  bucket = aws_s3_bucket.athena_result.id
}