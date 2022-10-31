terraform {
  required_version = ">= 1.2.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.4.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}