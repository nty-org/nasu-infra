# update-state
AWSリソースの状態を管理（夜間停止、再開処理等）する関数です。


# Requirement
デプロイはDockerとterraform、aws cliが必要となります。
ローカルでの開発、デプロイにはSAM CLIのインストールとドッカーのインストールが必要になります。

* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)
* terraform - [Install terraform cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* aws cli - [Install aws cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Python3 - [Python 3 installed](https://www.python.org/downloads/)


## 事前準備(AWSプロファイルの設定)


terraformの設定にて```profile = "##############################"```を指定しているので、awc profileの設定が必要となります。
aws configureコマンドでprofileを作り直すか、~/.aws/credentialのプロファイル名を直接編集してください

```
[##############################]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
```


## deploy

terraform管理ディレクトリにて、以下のコマンドにてterraformを使用できるようにします。

```
terraform init
```

ecr.tf内にて、lambdaイメージ用のECRを作成します。
```
# ------------------------------------------------------------#
#  updata state
# ------------------------------------------------------------#

resource "aws_ecr_repository" "updata_state" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "${local.PJPrefix}/${local.EnvPrefix}/updata-state"

  tags = {
    Service = "${local.PJPrefix}-${local.EnvPrefix}-updata-state"
  }
}
```

こちらのディレクトリにて、dockerイメージのビルドとecrへのpushを行います。

```
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com
```
```
docker build -t ${local.PJPrefix}/${local.EnvPrefix}/updata-state .
```
```
docker tag emomil/dev/api:latest ${locals.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${local.PJPrefix}/${local.EnvPrefix}/updata-state:latest
```
```
docker push emomil/dev/api:latest ${locals.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${local.PJPrefix}/${local.EnvPrefix}/updata-state:latest
```


lambda.tf内にて、lambda関数と関数用ロールの作成を行います。

```
# ------------------------------------------------------------#
#  updata state
# ------------------------------------------------------------#

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

resource "aws_iam_role" "lambda_updata_state" {
  assume_role_policy    = data.aws_iam_policy_document.lambda_updata_state_assume_role_policy.json
  max_session_duration  = "3600"
  name                  = "${local.PJPrefix}-${local.EnvPrefix}-lambda-updata-state-role"
  path                  = "/"
  managed_policy_arns   = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "${aws_iam_policy.lambda_updata_state.arn}"
  ]

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

```


# Usage


## AWSリソースの手動停止,再開
- lambdaコンソールに移動し、関数 > ${local.PJPrefix}-${local.EnvPrefix}-updata-state > テスト > に移動します。
- 仕様用途に応じ、以下のjsonを記入後、テストをクリックします。


### ECS、RDS両方の手動停止

```
{
  "ecs": [
    {
      "cluster": "${cluster_name}",
      "service": "${service_name}",
      "desiredCount": 0
    },
    {
      "cluster": "${ecs_cluster_name}",
      "service": "${ecs_service_name}",
      "desiredCount": 0
    }
  ],
  "rds": [
    {
      "DBClusterIdentifier": "${rds_cluster_name}",
      "action": "stop"
    }
  ]
}
```

### ECS、RDS両方の手動再開

```
{
  "ecs": [
    {
      "cluster": "${cluster_name}",
      "service": "${service_name}",
      "desiredCount": ${desire_task_count}
    },
    {
      "cluster": "${ecs_cluster_name}",
      "service": "${ecs_service_name}",
      "desiredCount": ${desire_task_count}
    },
    ・・・
  ],
  "rds": [
    {
      "DBClusterIdentifier": "${rds_cluster_name}",
      "action": "start"
    }
  ]
}
```


### ECS手動停止

```
{
  "ecs": [
    {
      "cluster": "${ecs_cluster_name}",
      "service": "${ecs_service_name}",
      "desiredCount": 0
    },
    ・・・
  ]
}
```

### ECS手動再開

```
{
  "ecs": [
    {
      "cluster": "${ecs_cluster_name}",
      "service": "${ecs_service_name}",
      "desiredCount": ${desire_task_count}
    },
    ・・・
  ]
}
```


### RDS手動停止

```
{
  "rds": [
    {
      "DBClusterIdentifier": "${rds_cluster_name}",
      "action": "stop"
    }
  ]
}
```

### RDS手動再開

```
{
  "rds": [
    {
      "DBClusterIdentifier": "${rds_cluster_name}",
      "action": "start"
    }
  ]
}
```

## 関数の更新
上記手順にて、Dockerイメージのpushを行った後、以下コマンドでlambdaを更新します。


```
aws lambda update-function-code --function-name ${local.PJPrefix}-${local.EnvPrefix}-updata-state --image-uri ${REPOSITORY_URI}:latest --publish --profile #############
```
