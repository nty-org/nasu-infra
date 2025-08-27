# ------------------------------------------------------------#
#  user 
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  app 
## ------------------------------------------------------------#
/*
resource "aws_iam_user" "s3" {
  force_destroy = "false"
  name          = "${local.PJPrefix}-${local.EnvPrefix}-app"
  path          = "/"
}

resource "aws_iam_user_policy_attachment" "s3" {
  policy_arn = aws_iam_policy.s3.arn
  user       = aws_iam_user.s3.name

}

resource "aws_iam_policy" "s3" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-s3"
  path   = "/"
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "s3:PutAccountPublicAccessBlock",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "VisualEditor1"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user_policy_attachment" "bedrock" {
  user       = aws_iam_user.s3.name
  policy_arn = aws_iam_policy.bedrock.arn

}

resource "aws_iam_policy" "bedrock" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-bedrock"
  path   = "/"
  policy = data.aws_iam_policy_document.bedrock.json
}

data "aws_iam_policy_document" "bedrock" {
  statement {
    sid       = "VisualEditor0"
    effect    = "Allow"
    actions   = ["bedrock:InvokeModel"]
    resources = ["*"]
  }
}
*/
## ------------------------------------------------------------#
##  opensearch
## ------------------------------------------------------------#
/*
resource "aws_iam_user" "opensearch" {
  force_destroy = "false"
  name          = "${local.PJPrefix}-${local.EnvPrefix}-opensearch"
  path          = "/"
}

resource "aws_iam_user_policy_attachment" "opensearch" {
  policy_arn = aws_iam_policy.opensearch.arn
  user       = aws_iam_user.opensearch.name

  depends_on = [
    aws_iam_user.opensearch
  ]
}

resource "aws_iam_policy" "opensearch" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-openserch-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.opensearch.json
}

data "aws_iam_policy_document" "opensearch" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutAccountPublicAccessBlock",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "VisualEditor1"
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "*"
    ]
  }
}
*/
# ------------------------------------------------------------#
#  oicd
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  terraform cloud
## ------------------------------------------------------------#
/*
resource "aws_iam_openid_connect_provider" "terraform-cloud" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity",
  ]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}
*/
## ------------------------------------------------------------#
##  github actions OIDC
## ------------------------------------------------------------#
/*
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}
*/
data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.github_actions.certificates[*].sha1_fingerprint
}

## ------------------------------------------------------------#
##  vercel
## ------------------------------------------------------------#
/*
resource "aws_iam_openid_connect_provider" "vercel_bastion" {
  url = "https://oidc.vercel.com/${local.vercel_team_slug}"

  client_id_list = [
    "https://vercel.com/${local.vercel_team_slug}",
  ]

  thumbprint_list = ["00abefd055f9a9c784ffdeabd1dcdd8fed741436"]
}
*/
# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  terraform cloud
## ------------------------------------------------------------#
/*
resource "aws_iam_openid_connect_provider" "terraform-cloud" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity",
  ]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

resource "aws_iam_role" "terraform-cloud" {
  name                = "terraform_cloud_oidc_role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  assume_role_policy  = data.aws_iam_policy_document.oicd_assume_role_policy.json
}

data "aws_iam_policy_document" "oicd_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/app.terraform.io"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:aud"
      values = [
        "aws.workload.identity",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      values = [
        "organization:ernie-infra:project:*:workspace:${local.PJPrefix}-${local.EnvPrefix}-infra:run_phase:*",
      ]
    }

  }
}
*/
## ------------------------------------------------------------#
##  github actions OIDC
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "github_actions" {
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume_role_policy.json
  max_session_duration = "3600"
  name                 = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-role"
  path                 = "/"

}

data "aws_iam_policy_document" "github_actions_assume_role_policy" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:usan73/nasu-infra:*"]
    }
  }
}

resource "aws_iam_policy" "github_actions" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "github_actions" {

  statement {
    effect = "Allow"
    actions = [
      "lambda:UpdateFunctionCode",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }

}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
*/
## ------------------------------------------------------------#
##  vercel
## ------------------------------------------------------------#
/*
resource "aws_iam_role" "vercel_bastion" {
  assume_role_policy    = data.aws_iam_policy_document.vercel_bastion_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-vercel-bastion-role"
  path                  = "/"

}

data "aws_iam_policy_document" "vercel_bastion_assume_role_policy" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${local.account_id}:oidc-provider/oidc.vercel.com/${local.vercel_team_slug}"]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.vercel.com/${local.vercel_team_slug}:sub"
      values   = ["owner:${local.vercel_team_slug}:project:${local.vercel_project_name}:environment:production"]
    }

    condition {
      test     = "StringLike"
      variable = "oidc.vercel.com/${local.vercel_team_slug}:aud"
      values   = ["https://vercel.com/${local.vercel_team_slug}"]
    }
  }
}

resource "aws_iam_policy" "vercel_bastion" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-vercel-bastion-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.vercel_bastion.json
}

data "aws_iam_policy_document" "vercel_bastion" {

  statement {
    effect = "Allow"
    actions = [
        "ssm:StartSession",
    ]
    resources = [
      aws_instance.rds_pf_bastion.arn,
      "arn:aws:ssm:*:*:document/AWS-StartPortForwardingSessionToRemoteHost",
    ]
  }

}
*/

## ------------------------------------------------------------#
##  github actions
## ------------------------------------------------------------#

### ------------------------------------------------------------#
###  terraform plan
### ------------------------------------------------------------#

resource "aws_iam_role" "github_actions_terraform_plan" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-terraform-plan-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_plan_assume_role_policy.json
}

data "aws_iam_policy_document" "github_actions_terraform_plan_assume_role_policy" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # 特定のリポジトリの全てのワークフローから認証を許可する
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:usan73/nasu-infra:*"]
    }
  }
}

resource "aws_iam_policy" "github_actions_terraform_plan_dynamo_access" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-github-actions-terraform-plan-dynamo-access-policy"
  policy = data.aws_iam_policy_document.github_actions_terraform_plan_dynamo_access.json
}

data "aws_iam_policy_document" "github_actions_terraform_plan_dynamo_access" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      data.aws_dynamodb_table.tfstate.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_plan_readonly" {
  role       = aws_iam_role.github_actions_terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_plan_dynamo_access" {
  role       = aws_iam_role.github_actions_terraform_plan.name
  policy_arn = aws_iam_policy.github_actions_terraform_plan_dynamo_access.arn
}

### ------------------------------------------------------------#
###  terraform apply
### ------------------------------------------------------------#

resource "aws_iam_role" "github_actions_terraform_apply" {
  name               = "oidc-github-actions-terraform-apply-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_terraform_apply_assume_role_policy.json
}

data "aws_iam_policy_document" "github_actions_terraform_apply_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # 特定リポジトリの特定ブランチのワークフローから認証を許可する
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:usan73/nasu-infra:environment:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions_terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}