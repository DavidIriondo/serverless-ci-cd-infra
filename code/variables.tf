variable "github_owner" {
  type        = string
  description = "GitHub organization or user that owns the repositories"
}


variable "task_def_front" {
  type        = string
  description = "Frontend task defintion ARN to run cluster"
  default     = null
}

variable "task_def_back" {
  type        = string
  description = "Backend task defintion ARN to run cluster"
  default     = null
}
