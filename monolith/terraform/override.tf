terraform {
  backend "s3" {
    bucket         = "nasu-prod-tfstate"
    dynamodb_table = "nasu-prod-tfstatelock"
    encrypt        = true
    key            = "tfstate_backend.tfstate"
    region         = "ap-northeast-1"
    profile        = "nasu-infra"

  }
}
