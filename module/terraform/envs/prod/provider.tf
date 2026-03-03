provider "aws" {
  region  = "ap-northeast-1"
  profile = "nasu-prod-infra"
}

provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "nasu-prod-infra"
}
