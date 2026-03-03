# ------------------------------------------------------------#
#  EC2
# ------------------------------------------------------------#
/*
data "aws_instance" "nat" {

  filter {
    name   = "tag:Name"
    values = ["${local.pj_prefix}-${local.env_prefix}-nat-a"]
  }

}
*/