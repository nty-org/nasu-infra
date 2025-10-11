# ------------------------------------------------------------#
#  instance
# ------------------------------------------------------------#

## -----------------------------------------------------------#
##  bastion 
## -----------------------------------------------------------#

data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_bastion.name
  #associate_public_ip_address = true#パブリックIP割り当て
  #disable_api_termination = false#終了保護

  #availability_zone =  
  subnet_id = var.subnet_id
  vpc_security_group_ids = [
    var.private_security_group_id
  ]
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = true
  }

  tags = {
    Name = "${var.pj_prefix}-${var.env_prefix}-bastion"
  }

}