# ------------------------------------------------------------#
#  build only
# ------------------------------------------------------------#

resource "aws_codebuild_project" "build_only" {
  name         = "${local.PJPrefix}-${local.EnvPrefix}-api-build-only"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    buildspec = "buildspec.yml"
    type      = "GITHUB"
    location  = "https://github.com/usan73/nasu-api"
  }

  source_version = "develop"

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DOCKER_BUILDKIT"
      value = "1"
    }

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

resource "aws_codebuild_source_credential" "build_only" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}

/*
resource "aws_codebuild_project" "build" {
  name         = "${local.PJPrefix}-${local.EnvPrefix}-monitoring-build-only"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    buildspec = "buildspec_buildonly.yml"
    type      = "GITHUB"
    location  = "https://github.com/ernie-mlg/ernie-call-monitoring"
  }

  source_version = "develop-ecs"

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
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

resource "aws_codebuild_source_credential" "build" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}
*/