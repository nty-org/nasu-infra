# ------------------------------------------------------------#
#  EC2 instances 
# ------------------------------------------------------------#

data "aws_instance" "ec2_instance" {
  for_each = var.ec2_instances

  filter {
    name   = "tag:Name"
    values = [each.value.instance_name]
  }
}