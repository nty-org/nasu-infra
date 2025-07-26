# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## -----------------------------------------------------------#
##  bastion 
## -----------------------------------------------------------#
/*
resource "aws_iam_instance_profile" "ec2_bastion" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-bastion-role"
  role = aws_iam_role.ec2_bastion.name
}

resource "aws_iam_role" "ec2_bastion" {
  assume_role_policy   = data.aws_iam_policy_document.ec2_bastion_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ec2-bastion-role"
  path                 = "/"

}

data "aws_iam_policy_document" "ec2_bastion_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ec2_bastion" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ec2-bastion-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_bastion.json
}


data "aws_iam_policy_document" "ec2_bastion" {

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log:*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "ec2_bastion" {
  role       = aws_iam_role.ec2_bastion.name
  policy_arn = aws_iam_policy.ec2_bastion.arn
}

resource "aws_iam_role_policy_attachment" "ec2_bastion_ssm" {
  role       = aws_iam_role.ec2_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
*/
## ------------------------------------------------------------#
##  code server
## ------------------------------------------------------------#

resource "aws_iam_instance_profile" "ec2_code_server" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-code-server-role"
  role = aws_iam_role.ec2_code_server.name
}

resource "aws_iam_role" "ec2_code_server" {
  assume_role_policy   = data.aws_iam_policy_document.ec2_code_server_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ec2-code-server-role"
  path                 = "/"

}

data "aws_iam_policy_document" "ec2_code_server_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}


resource "aws_iam_policy" "ec2_code_server" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ec2-code-server-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_code_server.json
}


data "aws_iam_policy_document" "ec2_code_server" {

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log:*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "ec2_code_server" {
  role       = aws_iam_role.ec2_code_server.name
  policy_arn = aws_iam_policy.ec2_code_server.arn
}

resource "aws_iam_role_policy_attachment" "ec2_code_server_ssm" {
  role       = aws_iam_role.ec2_code_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_instance" "code_server" {
  instance_id = "i-0529de0473e48c33c"
}

## ------------------------------------------------------------#
##  rds pf bastion
## ------------------------------------------------------------#
/*
resource "aws_iam_instance_profile" "ec2_rds_pf_bastion" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-rds-pf-bastion-role"
  role = aws_iam_role.ec2_rds_pf_bastion.name
}

resource "aws_iam_role" "ec2_rds_pf_bastion" {
  assume_role_policy   = data.aws_iam_policy_document.ec2_rds_pf_bastion_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ec2-rds-pf-bastion-role"
  path                 = "/"

}

data "aws_iam_policy_document" "ec2_rds_pf_bastion_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ec2_rds_pf_bastion" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ec2_rds-pf-bastion-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_rds_pf_bastion.json
}


data "aws_iam_policy_document" "ec2_rds_pf_bastion" {

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log:*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "ec2_rds_pf_bastion" {
  role       = aws_iam_role.ec2_rds_pf_bastion.name
  policy_arn = aws_iam_policy.ec2_rds_pf_bastion.arn
}

resource "aws_iam_role_policy_attachment" "ec2_rds_pf_bastion_ssm" {
  role       = aws_iam_role.ec2_rds_pf_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
*/

## ------------------------------------------------------------#
##  nat  role
## ------------------------------------------------------------#

resource "aws_iam_instance_profile" "ec2_nat" {
  name = "${local.PJPrefix}-${local.EnvPrefix}-ec2-nat-role"
  role = aws_iam_role.ec2_nat.name
}

resource "aws_iam_role" "ec2_nat" {
  assume_role_policy   = data.aws_iam_policy_document.ec2_nat_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-ec2-nat-role"
  path                 = "/"

}

data "aws_iam_policy_document" "ec2_nat_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "ec2_nat" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-ec2-nat-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2_nat.json
}


data "aws_iam_policy_document" "ec2_nat" {

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}/*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    resources = [
      "${aws_s3_bucket.ssm_log.arn}"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/ssm/${local.PJPrefix}-${local.EnvPrefix}-session-manager-log:*"
    ]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "ec2_nat" {
  role       = aws_iam_role.ec2_nat.name
  policy_arn = aws_iam_policy.ec2_nat.arn
}

resource "aws_iam_role_policy_attachment" "ec2_nat_ssm" {
  role       = aws_iam_role.ec2_nat.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------------------------------------------#
#  instance
# ------------------------------------------------------------#

## -----------------------------------------------------------#
##  bastion 
## -----------------------------------------------------------#
/*
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
  subnet_id = aws_subnet.private["ap-northeast-1c"].id
  vpc_security_group_ids = [
    aws_security_group.private.id
  ]
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = false 
  }

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-bastion"
  }

}
*/
## ------------------------------------------------------------#
##  rds pf bastion
## ------------------------------------------------------------#
/*
data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

resource "aws_instance" "rds_pf_bastion" {
  ami           = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type = "t2.micro"


  iam_instance_profile = aws_iam_instance_profile.ec2_rds_pf_bastion.name

  associate_public_ip_address = false

  subnet_id = aws_subnet.private["ap-northeast-1c"].id

  vpc_security_group_ids = [
    aws_security_group.private.id
  ]
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = false 
  }

  tags = {
    Name = "${local.PJPrefix}-${local.EnvPrefix}-rds-pf-bastion"
  }
  

  disable_api_termination = false
}
*/
