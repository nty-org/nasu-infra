# ブランチデプロイ環境 運用手順書

## 本書の目的
ブランチデプロイ環境の **初期構築・更新・環境変数更新・削除手順** を明確にし、運用の属人化を防ぐことを目的とする。

---

## 目次

- [本書の目的](#本書の目的)
- [初期構築](#初期構築)
- [更新](#更新)
- [環境変数更新](#環境変数更新)
- [削除](#削除)
- [タスク定義管理について](#タスク定義管理について)
  - [前提](#前提)
  - [CPU・memoryの変更方法](#CPU・memoryの変更方法)
  - [デプロイの仕組み](#デプロイの仕組み)

---

## 初期構築

### 手順

1. 該当リポジトリの **Actions ページ**へ移動する。
   - 対象リポジトリ：
     - [ernie-call-api](https://github.com/ernie-mlg/ernie-call-api)
     - [ernie-call-web](https://github.com/ernie-mlg/ernie-call-web)
     - [ernie-call-monitoring](https://github.com/ernie-mlg/ernie-call-monitoring)

   ※ 使用する際は、上記 3 サービスをすべて起動してください。

2. 画面左サイドバー内の **「DevMirage Initialize」** ワークフローを選択する。
3. **Run Workflow** をクリックし、以下を指定する：
   - デプロイするブランチ
   - デプロイする環境
4. **Run Workflow** を再度クリックして実行する。
5. 起動完了後、以下のドメインで動作確認を行う：

   | サービス   | ドメイン                                   |
   |------------|------------------------------------------|
   | api        | `api-${デプロイ環境名}.devmirage.yomel.co` |
   | web        | `web-${デプロイ環境名}.devmirage.yomel.co` |
   | monitoring | `sync-${デプロイ環境名}.devmirage.yomel.co` |

---

## 更新

### 手順

1. 該当リポジトリの **Actions ページ**へ移動する。
   - 対象リポジトリ：
     - [ernie-call-api](https://github.com/ernie-mlg/ernie-call-api)
     - [ernie-call-web](https://github.com/ernie-mlg/ernie-call-web)
     - [ernie-call-monitoring](https://github.com/ernie-mlg/ernie-call-monitoring)

2. 画面左サイドバー内の **「DevMirage Deploy」** ワークフローを選択する。
3. **Run Workflow** をクリックし、以下を入力：
   - デプロイブランチ
   - デプロイ環境
   - DB 初期化の有無(trueの場合、DBを再作成)

4. 起動完了後、以下のドメインで動作確認を行う：

   | サービス   | ドメイン                                   |
   |------------|------------------------------------------|
   | API        | `api-${デプロイ環境名}.devmirage.yomel.co` |
   | Web        | `web-${デプロイ環境名}.devmirage.yomel.co` |
   | Monitoring | `sync-${デプロイ環境名}.devmirage.yomel.co` |

---

## 環境変数更新

### 手順

1. **yomel-dev 環境** の Secrets Manager コンソールにアクセスする。
2. 該当する環境・サービスのシークレットをクリックする。

   | サービス   | シークレット名                     |
   |------------|----------------------------------|
   | API        | `yomel/${デプロイ環境名}/api`       |
   | Web        | `yomel/${デプロイ環境名}/web`       |
   | Monitoring | `yomel/${デプロイ環境名}/monitoring` |

3. **「概要」 > 「シークレットの値」 > 「シークレットの値を取得する」** をクリック。
4. **「編集する」** をクリックし、値を編集して「保存」。
5. 編集後、更新手順（DevMirage Deploy）にしたがって再デプロイを実施する。

---

## 削除

### 手順

1. 該当リポジトリの **Actions ページ**へ移動する。
   - 対象リポジトリ：
     - [ernie-call-api](https://github.com/ernie-mlg/ernie-call-api)
     - [ernie-call-web](https://github.com/ernie-mlg/ernie-call-web)
     - [ernie-call-monitoring](https://github.com/ernie-mlg/ernie-call-monitoring)

2. 画面左サイドバー内の **「DevMirage Delete」** ワークフローを選択する。
3. **Run Workflow** をクリックし、以下を指定：
   - 削除する環境
4. 実行後、対象環境が削除される。

---

## タスク定義管理について

### 前提

- 各環境のタスク定義は以下のディレクトリで管理されている。
```
.
├── deploy
│   ├── develop4 
│   │   ├── api # api用
│   │   │   └── ecs-task-def.json
│   │   ├── db-deploy # DB初期化用
│   │   │   └── ecs-task-def.json
│   │   ├── migrate # migrate用
│   │   │   └── ecs-task-def.json
│   │   └── worker # worker用
│   │       └── ecs-task-def.json
│   ├── develop5
│   ...
```

### CPU・memoryの変更方法

1. タスク定義の以下の部分を編集する
    - [ernie-call-api/blob/develop/deploy/yomel/develop4/api/ecs-task-def.json#L145](https://github.com/ernie-mlg/ernie-call-api/blob/develop/deploy/yomel/develop4/api/ecs-task-def.json#L145)
```
  "cpu": "512",
  "memory": "1024"
```
- 値は下記を参考
    - https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size

2. 上記のタスク定義ファイルを編集してコミット
3. 「更新」セクションの手順に従って再デプロイを実施


### デプロイの仕組み

1. タスク定義を登録
   - [devmirage_deploy.yml#L629](https://github.com/ernie-mlg/ernie-call-api/blob/develop/.github/workflows/devmirage_deploy.yml#L629)

```
echo "Register Task Definition"
if ! aws ecs register-task-definition --cli-input-json file://ecs-task-def.json; then
  echo "Error: Failed to register task definition"
  cat ecs-task-def.json  # デバッグ用に内容を出力
  exit 1
fi
```

2. ECSタスクを起動
   - [/ecs-deploy.yml#L165](https://github.com/ernie-mlg/ernie-call-api/blob/develop/.github/workflows/ecs-deploy.yml#L165)

```
echo "Deploy ECS Task"
echo "${TASKDEF_NAME}"
jq -n \
  --arg SUBDOMAIN "${SUBDOMAIN}" \
  --arg BRANCH "${BRANCH}" \
  --arg TASKDEF_NAME "${TASKDEF_NAME}" \
'{
  "subdomain": $SUBDOMAIN,
  "taskdef": [$TASKDEF_NAME],
  "branch": $BRANCH,
  "parameters": {
  }
}' > mirage-ecs-conf.json
curl https://mirage.${DOMAIN_NAME}/api/launch --header 'x-mirage-token: ${{ env.ECS_MIRAGE_TOKEN }}' --header 'Content-Type: application/json' -d @mirage-ecs-conf.json --fail
```
- 参考
    - https://github.com/acidlemon/mirage-ecs?tab=readme-ov-file#api-usage