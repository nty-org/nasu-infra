# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  synthetics
## ------------------------------------------------------------#

resource "aws_iam_role" "synthetics" {
  name               = "${var.pj_prefix}-${var.env_prefix}-synthetics-role"
  assume_role_policy = data.aws_iam_policy_document.synthetics_assume_role_policy.json
  description        = "IAM role for AWS Synthetic Monitoring Canaries"

}

data "aws_iam_policy_document" "synthetics_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_policy" "synthetics" {
  name        = "${var.pj_prefix}-${var.env_prefix}-synthetics-policy"
  policy      = data.aws_iam_policy_document.synthetics.json
  description = "IAM role for AWS Synthetic Monitoring Canaries"

}

data "aws_iam_policy_document" "synthetics" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets"
    ]
    resources = [
      aws_s3_bucket.synthetics.arn,
      "${aws_s3_bucket.synthetics.arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListAllMyBuckets"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:ap-northeast-1:${var.account_id}:log-group:/aws/lambda/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["CloudWatchSynthetics"]
      variable = "cloudwatch:namespace"
    }
  }
}

resource "aws_iam_role_policy_attachment" "synthetics" {
  role       = aws_iam_role.synthetics.name
  policy_arn = aws_iam_policy.synthetics.arn
}

resource "aws_iam_role_policy_attachment" "synthetics_lambda_vpc_acccess" {
  role       = aws_iam_role.synthetics.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
