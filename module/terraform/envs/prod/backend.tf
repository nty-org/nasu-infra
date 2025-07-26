terraform {
  # local用
  /*
  backend "local" {
    path = "terraform.tfstate"
  }
*/
  # terraform cloud用
  /*
  cloud {
    organization = "nasu-infra"
    workspaces {
      name = "nasu-prod-infra"
    }
  }
*/
  # s3用
  backend "s3" {
    bucket         = "nasu-prod-tfstate"
    dynamodb_table = "nasu-prod-tfstatelock"
    encrypt        = true
    key            = "tfstate_backend_module.tfstate"
    region         = "ap-northeast-1"
    profile        = "nasu-infra"

  }
}