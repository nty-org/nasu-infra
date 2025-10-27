# ------------------------------------------------------------#
#  alb access log
# ------------------------------------------------------------#

resource "aws_athena_workgroup" "alb_access_log" {
  name = "${var.pj_prefix}-${var.env_prefix}-alb-access-log"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_result.id}/alb-access-log/"
    }
  }
  
  force_destroy = true

}

resource "aws_athena_database" "alb_access_log" {
  name   = "alb_db"
  bucket = aws_s3_bucket.athena_result.id

  force_destroy = true
  
}