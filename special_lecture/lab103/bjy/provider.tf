terraform {
  required_version = ">= 1.2.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 4.4.0"
    }
  }

  backend "s3" {
    dynamodb_table = "bjy-terraform-lock"
    key            = "bjy-dev/terraform.tfstate"
    acl            = "bucket-owner-full-control"
    bucket         = "bjy-terraform-repo"
    encrypt        = true
    region         = "ap-northeast-2"
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}