# ------------------------------------------------------------#
#  security group
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  ec2 ws
## ------------------------------------------------------------#

resource "aws_security_group" "ec2_ws" {
  description = "sg for ${var.pj_prefix}-${var.env_prefix}-ec2-ws-sg"
  name        = "${var.pj_prefix}-${var.env_prefix}-ec2-ws-sg"

  tags = {
    Name = "${var.pj_prefix}-${var.env_prefix}-ec2-ws-sg"
  }

  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ec2_ws_default_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_ws.id
  to_port           = "0"
  type              = "egress"
}

resource "aws_security_group_rule" "ec2_ws_allow_all_from_specific_ip" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" 
  security_group_id = aws_security_group.ec2_ws.id
  cidr_blocks       = var.allowed_cidr_blocks
  description       = "Allow all traffic from trusted IP"
}