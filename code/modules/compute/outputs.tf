output "ecr_for_backend" {
  value = aws_ecr_repository.backend.name
}

output "ecr_for_frontend" {
  value = aws_ecr_repository.frontend.name
}