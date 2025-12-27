output "ecr_for_backend" {
  value = aws_ecr_repository.backend.arn
}

output "ecr_for_frontend" {
  value = aws_ecr_repository.frontend.arn
}
