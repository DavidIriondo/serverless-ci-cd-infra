variable "github_owner" {
  type        = string
  description = "GitHub organization or user that owns the repositories"
}

variable "ecr_arn" {
  type = map(string)
  description = "ARN value of front ecr and back ecr"
}