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
    key            = "tfstate_backend.tfstate"
    region         = "ap-northeast-1"
    profile        = "nasu-infra"

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "1.4.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.5.0"
    }

  }

  required_version = ">= 1.7.3"
}


provider "aws" {
  region  = "ap-northeast-1"
  profile = "nasu-infra"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = "nasu-infra"
}
/*
provider "sops" {}

data "sops_file" "secrets_api" {
  source_file = "secrets_api.enc.json"
}

data "sops_file" "secrets_web" {
  source_file = "secrets_web.enc.json"
}

data "sops_file" "secrets_monitoring" {
  source_file = "secrets_monitoring.enc.json"
}
*/

provider "awscc" {
  region  = "ap-northeast-1"
  profile = "nasu-infra"
}

provider "archive" {}
