# ------------------------------------------------------------#
#  table
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  tfstate
## ------------------------------------------------------------#

resource "aws_dynamodb_table" "tfstate" {
  name         = "${local.PJPrefix}-${local.EnvPrefix}-tfstatelock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}