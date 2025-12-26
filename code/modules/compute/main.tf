//Ecr for frontend images
resource "aws_ecr_repository" "frontend" {
  name                 = "scc-frontend"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

//Ecr for backend images
resource "aws_ecr_repository" "backend" {
  name                 = "scc-backend"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

