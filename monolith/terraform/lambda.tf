# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  updata state
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "lambda_updata_state" {
  assume_role_policy    = data.aws_iam_policy_document.lambda_updata_state_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-lambda-updata-state-role"
  path                  = "/"

}

data "aws_iam_policy_document" "lambda_updata_state_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "lambda_updata_state" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-lambda-updata-state-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_updata_state.json
}

data "aws_iam_policy_document" "lambda_updata_state" {
  statement {
    effect = "Allow"
    actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
        "ecs:DescribeServices",
        "ecs:UpdateService"
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
        "rds:StartDBCluster",
        "rds:StopDBCluster"
    ]
    resources = [
      "*",
    ]
  }

}

resource "aws_iam_role_policy_attachment" "lambda_updata_state" {
  role       = aws_iam_role.lambda_updata_state.name
  policy_arn = aws_iam_policy.lambda_updata_state.arn
}

resource "aws_iam_role_policy_attachment" "lambda_updata_state_basic_execution" {
  role       = aws_iam_role.lambda_updata_state.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_updata_state_vpc_access" {
  role       = aws_iam_role.lambda_updata_state.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
*/
# ------------------------------------------------------------#
#  function
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  updata state
## ------------------------------------------------------------#
/*
resource "aws_lambda_function" "updata_state" {
  function_name = "${local.PJPrefix}-${local.EnvPrefix}-updata-state"
  role          = aws_iam_role.lambda_updata_state.arn

  image_uri     = "${aws_ecr_repository.updata_state.repository_url}:latest"
  architectures = ["x86_64"]
  package_type  = "Image"

  timeout = 30
  memory_size = 128

  environment {
    variables = {
    }
  }

}
*/
## ------------------------------------------------------------#
##  templete
## ------------------------------------------------------------#
/*
resource "aws_lambda_function" "templete" {
  function_name = "${local.PJPrefix}-${local.EnvPrefix}-templete"
  role          = aws_iam_role.lambda_cognito_user.arn

  image_uri     = "${aws_ecr_repository.templete.repository_url}:latest"
  #architectures = ["x86_64"]
  package_type  = "Image"

  timeout = 30
  #memory_size = 128

  environment {
    variables = {
      COGNITO_ENDPOINT_URL = "api.${local.zone_name}",
      IS_AUTH_TOKEN        = "false",
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.private.id]
  }

}

data "aws_lambda_function" "cognito_user" {
  function_name = "${local.PJPrefix}-${local.EnvPrefix}-templete"
}
*/
