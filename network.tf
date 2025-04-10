# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "${local.project}-vpc"
  cidr = var.vpc_cidr

  azs                 = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  public_subnets      = ["10.10.10.0/24", "10.10.11.0/24", "10.10.12.0/24"]
  public_subnet_names = ["${local.project}-pub-a", "${local.project}-pub-b", "${local.project}-pub-c"]
  public_route_table_tags = {
    Name = "${local.project}-pub-rt"
  }

  private_subnets      = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_names = ["${local.project}-priv-a", "${local.project}-priv-b", "${local.project}-priv-c"]
  private_route_table_tags = {
    Name = "${local.project}-priv-rt"
  }

  single_nat_gateway = true
  enable_nat_gateway = true
}