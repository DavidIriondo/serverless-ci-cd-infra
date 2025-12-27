output "github_actions_role_arn" {
  value = aws_iam_role.ecr_and_ecs_role.arn
  description = "Role arn to be used in github actions"
}
