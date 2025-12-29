resource "aws_ecs_cluster" "main" {
  name = "scc-cluster"
}

//Task definition for frontend container
resource "aws_ecs_task_definition" "frontend" {
  family                = "scc-frontend-task"
  execution_role_arn    = var.ecs_task_execute_role
  container_definitions = local.template_front

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024 //1 vCPU
  memory                   = 2048 //2GB

  runtime_platform {
    operating_system_family = "Linux"
    cpu_architecture        = "X86_64"
  }
}

//Task definition for backend container
resource "aws_ecs_task_definition" "backend" {
  family                = "scc-backend-task"
  execution_role_arn    = var.ecs_task_execute_role
  container_definitions = local.template_back

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024 //1 vCPU
  memory                   = 2048 //2GB

  runtime_platform {
    operating_system_family = "Linux"
    cpu_architecture        = "X86_64"
  }
}


locals {
  template_front = templatefile("${path.module}/", {
    name           = "scc-frontend"
    image          = "don't know yet"
    cpu            = 1024
    memory         = 2048
    container_port = 80
    host_port      = 80
  })

  template_back = templatefile("${path.module}/", {
    name           = "scc-backend"
    image          = "don't know yet"
    cpu            = 1024
    memory         = 2048
    container_port = 80
    host_port      = 80
  })
}
