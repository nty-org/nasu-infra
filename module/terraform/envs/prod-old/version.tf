terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.5.0"
    }

  }

  required_version = ">= 1.7.3"
}