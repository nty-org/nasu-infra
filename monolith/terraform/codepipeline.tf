# ------------------------------------------------------------#
#  role
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  codepipeline
## ------------------------------------------------------------#

resource "aws_iam_role" "codepipeline" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-codepipeline-role"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codepipeline" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-pipeline-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.codepipeline_service_role_policy.json
}

data "aws_iam_policy_document" "codepipeline_service_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "codecommit:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codedeploy:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "opsworks:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudformation:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "devicefarm:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "servicecatalog:*",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudformation:ValidateTemplate"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:DescribeImages"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "states:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "appconfig:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

## ------------------------------------------------------------#
##  codebuild
## ------------------------------------------------------------#

resource "aws_iam_role" "codebuild" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-codebuild-role"
  path               = "/service_role/"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "${local.PJPrefix}-${local.EnvPrefix}-build-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.codebuild_service_role_policy.json
}

data "aws_iam_policy_document" "codebuild_service_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "kms:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:*",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:*"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecs:*",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["arn:aws:iam::${local.account_id}:role/${local.PJPrefix}-${local.EnvPrefix}-ecs-task-role"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = [for id, subnet in data.aws_subnet.private : subnet.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter*",
      "secretsmanager:*",
    ]
    resources = ["*"]
  }

}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

## ------------------------------------------------------------#
##  codedeploy
## ------------------------------------------------------------#

resource "aws_iam_role" "codedeploy" {
  name               = "${local.PJPrefix}-${local.EnvPrefix}-codedeploy-role"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_service_assume_role_policy.json
}

data "aws_iam_policy_document" "codedeploy_service_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_codedeploy_service_role_AWSCodeDeployRoleForECS" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# ------------------------------------------------------------#
#  codestar
# ------------------------------------------------------------#

resource "aws_codestarconnections_connection" "this" {
  name          = "${local.PJPrefix}-${local.EnvPrefix}-github"
  provider_type = "GitHub"
}

# ------------------------------------------------------------#
#  s3
# ------------------------------------------------------------#

resource "aws_s3_bucket" "codepipeline_artifact" {
  bucket = "${local.PJPrefix}-${local.EnvPrefix}-pipeline"
}

# ------------------------------------------------------------#
#  codepipeline 
# ------------------------------------------------------------#

## ------------------------------------------------------------#
##  codepipeline build_only
## ------------------------------------------------------------#
/*
resource "aws_codepipeline" "build_only" {
  name     = "${local.PJPrefix}-${local.EnvPrefix}-build-only-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      namespace        = "SourceVariables"
      category         = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"

      configuration = {
        BranchName             = "main"
        ConnectionArn          = aws_codestarconnections_connection.main.arn
        FullRepositoryId       = "usan73/nasu-api"
        "OutputArtifactFormat" = "CODE_ZIP"
      }
    }
  }

  lifecycle {
    ignore_changes = [

    ]
  }


  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        "NotificationArn" = "arn:aws:sns:ap-northeast-1:267751904634:nasu-prod-slack"
      }

    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }

    }


  }

  depends_on = [
    aws_codebuild_project.build
  ]
}

## ------------------------------------------------------------#
##  codebuild build_only
## ------------------------------------------------------------#

resource "aws_codebuild_project" "build" {
  name         = "${local.PJPrefix}-${local.EnvPrefix}-build-only-build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    buildspec = "buildspec.yml"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "CONTAINER_NAME"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/api/CONTAINER_NAME"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/AWS_ACCOUNT_ID"
    }

    environment_variable {
      name  = "IMAGE_REPOSITORY_NAME"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/api/IMAGE_REPOSITORY_NAME"
    }

  }

  build_timeout      = "60"
  queued_timeout     = "70"
  project_visibility = "PRIVATE"

  vpc_config {
    vpc_id             = aws_vpc.this.id
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.private.id]
  }
}
*/
## ------------------------------------------------------------#
##  codepipeline app
## ------------------------------------------------------------#
/*
resource "aws_codepipeline" "app" {
  name     = "${local.PJPrefix}-${local.EnvPrefix}-app-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      namespace        = "SourceVariables"
      category         = "Source"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"

      configuration = {
        BranchName             = "main"
        ConnectionArn          = aws_codestarconnections_connection.main.arn
        FullRepositoryId       = "usan73/bg-gitrp05"
        "OutputArtifactFormat" = "CODE_ZIP"
      }
    }
  }

  lifecycle {
    ignore_changes = [
     
    ]
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      namespace        = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.app.name
      }
    }

  }

  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.this.name
        FileName    = "imageDetail.json"
        ServiceName = aws_ecs_service.app.name
      }

      input_artifacts = ["BuildArtifact"]
      namespace       = "DeployVariables"

    }
  }
  depends_on = [
    aws_codebuild_project.app
  ]
}

## ------------------------------------------------------------#
##  codebuild app
## ------------------------------------------------------------#

resource "aws_codebuild_project" "app" {
  name         = "${local.PJPrefix}-${local.EnvPrefix}-app-build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    buildspec = "buildspec.yml"
    type      = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
    
    environment_variable {
      name  = "CONTAINER_NAME"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/app/CONTAINER_NAME"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/AWS_ACCOUNT_ID"
    }

    environment_variable {
      name  = "IMAGE_REPOSITORY_NAME"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/app/IMAGE_REPOSITORY_NAME"
    }

    environment_variable {
      name  = "NETWORK_CONFIG"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/app/NETWORK_CONFIG"
    }

    environment_variable {
      name  = "CLUSTER_NAME"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/app/CLUSTER_NAME"
    }

    environment_variable {
      name  = "TASKDEF_NAME_MIGRATE"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/app/TASKDEF_NAME_MIGRATE"
    }

    environment_variable {
      name  = "DB_MIGRATE"
      type  = "PARAMETER_STORE"
      value = "/${local.PJPrefix}/${local.EnvPrefix}/DB_MIGRATE"
    }

  }

  build_timeout      = "60"
  queued_timeout     = "70"
  project_visibility = "PRIVATE"

  vpc_config {
    vpc_id             = aws_vpc.this.id
    subnets            = data.aws_subnets.private.ids
    security_group_ids = [aws_security_group.private.id]
  }
}
*/
/*
## ------------------------------------------------------------#
##  codedeploy app
## ------------------------------------------------------------#

resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = "ECS-app"
}

resource "aws_codedeploy_deployment_group" "app_blue_green" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "ECS-BlueGreen-app-dg"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.app.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.app_http.arn]
      }

      target_group {
        name = aws_lb_target_group.app["blue"].name
      }

      target_group {
        name = aws_lb_target_group.app["green"].name
      }
    }
  }
}
*/