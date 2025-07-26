provider "aws" {
  region  = "ap-northeast-1"
  profile = "nasu-infra"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "nasu-infra"
}

provider "awscc" {
  region  = "ap-northeast-1"
  profile = "nasu-infra"
}

provider "archive" {}
