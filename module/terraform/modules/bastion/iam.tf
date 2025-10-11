# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## -----------------------------------------------------------#
##  bastion 
## -----------------------------------------------------------#

resource "aws_iam_instance_profile" "ec2_bastion" {
  name = "${var.pj_prefix}-${var.env_prefix}-ec2-bastion-role"
  role = aws_iam_role.ec2_bastion.name
}

resource "aws_iam_role" "ec2_bastion" {
  assume_role_policy   = data.aws_iam_policy_document.ec2_bastion_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${var.pj_prefix}-${var.env_prefix}-ec2-bastion-role"
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
/*
resource "aws_iam_policy" "ec2_bastion" {
  name   = "${var.pj_prefix}-${var.env_prefix}-ec2-bastion-policy"
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
      "arn:aws:logs:ap-northeast-1:${local.account_id}:log-group:/ssm/${var.pj_prefix}-${var.env_prefix}-session-manager-log:*"
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
*/
resource "aws_iam_role_policy_attachment" "ec2_bastion_ssm" {
  role       = aws_iam_role.ec2_bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
