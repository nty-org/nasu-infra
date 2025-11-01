# -------------------------------------------------------------#
#  vpc flowlog
# -------------------------------------------------------------#

resource "aws_flow_log" "vpc_flowlog" {
  log_destination      = aws_s3_bucket.vpc_flowlog.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.aws_vpc_id
  tags = {
    Name = "${var.pj_prefix}-${var.env_prefix}-vpc-flowlog"
  }
}
