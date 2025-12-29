output "github_actions_role_arn" {
  value = aws_iam_role.ecr_and_ecs_role.arn
  description = "Role arn to be used in github actions"
}

output "ecs_task_execute_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn
  description = "Role arn to be used in ecs task"
}
