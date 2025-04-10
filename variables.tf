variable "vpc_cidr" {
  description = "VPC 대역대"
  type        = string
}

variable "keypair_name" {
  description = "bastion에 사용할 키페어 이름"
  type        = string
}