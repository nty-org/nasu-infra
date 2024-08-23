# ------------------------------------------------------------#
#  bastion
# ------------------------------------------------------------#

resource "aws_iam_role" "bastion" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-ec2-role"
  path                  = "/"
  description           = "Allows EC2 instances to call AWS services on your behalf."
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-role"
  role = aws_iam_role.bastion.name
}


data "aws_ami" "bastion" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240223.0-x86_64-gp2"]
  }

  #include_deprecated = false
}



resource "aws_instance" "bastion" {
  ami           = data.aws_ami.bastion.id 
  instance_type = "t2.micro"


  iam_instance_profile = aws_iam_instance_profile.bastion.name

  #associate_public_ip_address = true#パブリックIP割り当て

  #availability_zone =  
  subnet_id = aws_subnet.private["ap-northeast-1c"].id

  vpc_security_group_ids = [
    aws_security_group.private.id
  ]

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-bastion"
  }
  

  #disable_api_termination = false#終了保護
}

