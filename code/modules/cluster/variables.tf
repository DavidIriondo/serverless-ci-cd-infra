variable "ecs_task_execute_role" {
  type        = string
  description = "Role arn to be used in ecs task"
}

variable "alb_subnets_ids" {
  type        = list(string)
  description = "ALB subnets ids"
}

variable "alb_security_group_ids" {
  type        = list(string)
  description = "ALB security gruops ids"
}

variable "ecs_task_security_group_id" {
  type        = string
  description = "ECS security group that only allows alb to connect with cluster"
}

variable "front_subnet_id" {
  type        = string
  description = "private subnet for frontend web"
}

variable "back_subnet_id" {
  type        = string
  description = "private subnet for backend microservices"
}

variable "vpc" {
  type        = string
  description = "VPC id"
}

variable "task_definition_front" {
  type        = string
  description = "Frontend task defintion ARN to run cluster"
  default     = null
}

variable "task_definition_back" {
  type        = string
  description = "Backend task defintion ARN to run cluster"
  default     = null
}
