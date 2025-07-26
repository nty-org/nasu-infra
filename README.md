# nasu-infra

## 目次

- [nasu-infra](#nasu-infra)
  - [目次](#目次)
  - [使用技術一覧](#使用技術一覧)
  - [環境構築](#環境構築)
    - [事前にインストールするもの](#事前にインストールするもの)
    - [手順](#手順)
  - [開発時に利用するコマンド一覧](#開発時に利用するコマンド一覧)
  - [Git 運用ルール](#git-運用ルール)



## 使用技術一覧

- [terraform](https://www.terraform.io/)
- [asdf](https://asdf-vm.com/)
- [tfenv](https://github.com/tfutils/tfenv)

## 環境構築

### 事前にインストールするもの

- [asdf](https://asdf-vm.com/guide/getting-started.html)
または
- [tfenv](https://github.com/tfutils/tfenv?tab=readme-ov-file#installation)

### 手順

1. リポジトリ clone

```
git clone git@github.com:usan73/nasu-infra.git
```

2. terraform install

asdfの場合

```
asdf install terraform 1.7.3
asdf local terraform 1.7.3
$PWD/.tool-versions
terraform --version
```

tfenvの場合

```
tfenv install 1.7.3
tfenv list
terraform --version
```

3. aws credential設定

settings.tfにて```profile = "##############################"```を指定しているので、awc profileの設定が必要となります。
aws configureコマンドでprofileを作成するか、~/.aws/credentialのプロファイル名を直接編集してください

```
[##############################]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
```

5. terraform init

```
terraform init
```

## 開発時に利用するコマンド一覧

terraform fmt(フォーマットの修正)

```
terraform fmt
```

terraform plan(適用結果の事前確認)

```
terraform plan
```

terraform apply(適用)

```
terraform apply
```


## Git 運用ルール

以下のGitワークフローを採用しています。

### ブランチ命名規則

新しい作業を行う際は、名前を以下のフォーマットに従って付け、ブランチを作成してください。

```
feature/<Task Name>
```

例

```
feature/add-ecs-cpu-monitoring
```

### コミット命名規則

作業内容の種別により、以下のプレフィックスをコミット名につけてください。

```
feat: A new feature
fix: A bug fix
docs: Documentation only changes 
style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
refactor: A code change that neither fixes a bug nor adds a feature
perf: A code change that improves performance
test: Adding missing or correcting existing tests
chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
```

## ディレクトリ構成

<pre>
.
├── .github # actions用のディレクトリ
├── lambda-fuction # lambda関数用のディレクトリ
├── monolith # 小~中規模向きモノリス構成のインフラディレクトリ
├── module # 中~大規模向きモジュール構成のインフラディレクトリ
├── .gitignore 
└── README.md 
</pre>