# AWS 지역 정보 불러오기
data "aws_region" "current" {}

# 현재 설정된 AWS 리전에 있는 가용영역 정보 불러오기
data "aws_availability_zones" "azs" {}

# 현재 Terraform을 실행하는 IAM 객체
data "aws_caller_identity" "current" {}


resource "aws_ssm_parameter" "auth_token" {
  name  = "/auth-server/AUTH_TOKEN"
  type  = "SecureString"
  value = "token"
}

resource "aws_ssm_parameter" "ddb_table" {
  name  = "/auth-server/DDB_TABLE_NAME"
  type  = "String"
  value = "skills-ddb"
}

resource "aws_ssm_parameter" "region" {
  name  = "/auth-server/AWS_REGION"
  type  = "String"
  value = "ap-northeast-2"
}
