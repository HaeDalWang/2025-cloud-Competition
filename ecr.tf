module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.2.1"

  for_each                        = toset(["api", "auth", "frontend"])
  repository_image_tag_mutability = "MUTABLE"
  repository_name                 = each.key

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "imageCountMoreThan",
          countNumber = 3
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
