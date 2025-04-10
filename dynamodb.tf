resource "aws_dynamodb_table" "skills_ddb" {
  name         = "skills-ddb"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  hash_key = "id"

  tags = {
    Name = "skills-ddb"
  }
}
