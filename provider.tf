# 요구되는 테라폼 제공자 목록
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.56.0"
    }
  }
}

# AWS 제공자 설정
provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = local.tags
  }
}