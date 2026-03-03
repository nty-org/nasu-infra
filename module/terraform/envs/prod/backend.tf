terraform {
  # s3
  backend "s3" {
    bucket         = "nasu-prod-tfstate02"
    encrypt        = true
    key            = "root.tfstate"
    region         = "ap-northeast-1"
    use_lockfile   = true
    profile        = "nasu-prod-infra"
  }
}