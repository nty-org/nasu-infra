# ------------------------------------------------------------#
#  eventbrige scheduler night stop EC2 instances 
# ------------------------------------------------------------#

data "aws_instance" "ec2_instance" {
  for_each = var.ec2_night_stop_instances

  filter {
    name   = "tag:Name"
    values = [each.value.instance_name]
  }
}