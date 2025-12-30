output "region" {
  value       = "eu-north-1"
  description = "Role arn to be used in github actions"
}

output "ecr_for_backend" {
  value = module.compute.ecr_for_backend
}

output "ecr_for_frontend" {
  value = module.compute.ecr_for_frontend
}

output "github_actions_role_arn" {
  value       = module.security.github_actions_role_arn
  description = "Role arn to be used in github actions"
}

output "alb_hostname" {
  value = module.cluster.alb_hostname
  description = "ALB dns"
}

output "application_url" {
  value = module.cluster.application_url
  description = "URL to access the application"
}