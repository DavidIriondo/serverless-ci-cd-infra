resource "aws_ecs_cluster" "main" {
  name = "scc-cluster"
}

//Application load baalncer
resource "aws_alb" "main" {
  name            = "scc-alb"
  subnets         = var.alb_subnets_ids
  security_groups = var.alb_security_group_ids
}

resource "aws_alb_target_group" "front" {
  name        = "scc-alb-front-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_target_group" "back" {
  name        = "scc-alb-back-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_alb_listener_rule" "alb_front_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/front/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.front.arn
  }
}

resource "aws_alb_listener_rule" "alb_back_rule" {
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = 20

  condition {
    path_pattern {
      values = ["/back/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.back.arn
  }
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
    operating_system_family = "LINUX"
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
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "scc-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_task_security_group_id]
    subnets          = [var.front_subnet_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.front.arn
    container_name   = "scc-frontend"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.alb_listener]

}

resource "aws_ecs_service" "backend_service" {
  name            = "scc-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_task_security_group_id]
    subnets          = [var.back_subnet_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.back.arn
    container_name   = "scc-backend"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.alb_listener]

}

locals {
  template_front = templatefile("${path.cwd}/templates/container_definition.json", {
    name           = "scc-frontend"
    image          = "public.ecr.aws/nginx/nginx:stable-alpine"
    aws_region     = "eu-north-1"
    cpu            = 1024
    memory         = 2048
    container_port = 80
    host_port      = 80
  })

  template_back = templatefile("${path.cwd}/templates/container_definition.json", {
    name           = "scc-backend"
    image          = "public.ecr.aws/nginx/nginx:stable-alpine"
    aws_region     = "eu-north-1"
    cpu            = 1024
    memory         = 2048
    container_port = 80
    host_port      = 80
  })
}
