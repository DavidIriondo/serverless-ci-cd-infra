resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

}

resource "aws_iam_role" "ecr_and_ecs_role" {
  name               = "scc-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.oidc.json

  tags = {
    Name = "scc-github-actions-role"
  }
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_owner}/*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}


data "aws_iam_policy_document" "push_images_to_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "push_images_to_ecr" {
  name        = "scc-push-images-to-ecr"
  description = "Policy used for upload container on CI"
  policy      = data.aws_iam_policy_document.push_images_to_ecr.json
}

resource "aws_iam_role_policy_attachment" "attach_push_images_to_ecr" {
  role       = aws_iam_role.ecr_and_ecs_role.name
  policy_arn = aws_iam_policy.push_images_to_ecr.arn
}


//New role for execute containers in ecs
//aws creates this role by default so lets create the same role to avoid runtime errors when
// we'll applied changes
resource "aws_iam_role" "ecs_task_execution" {
  name               = "scc-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_execution_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name   = "scc-ecs-task-execution-policy"
  policy = data.aws_iam_policy_document.ecs_task_execution_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}


//Security groups for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "scc-alb-security-group"
  description = "Control access to ALB"
  vpc_id      = var.vpc
}

resource "aws_vpc_security_group_ingress_rule" "allows_http" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = "80"
  to_port           = "80"
}

resource "aws_vpc_security_group_egress_rule" "allows_alb_access_to_all_internet" {
  security_group_id = aws_security_group.alb_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


//ECS Task security group
resource "aws_security_group" "ecs_task_security_group" {
  name        = "scc-ecs-security-group"
  description = "Allow inbound access only from ALB"
  vpc_id      = var.vpc
}

resource "aws_vpc_security_group_ingress_rule" "allows_access_from_alb" {
  security_group_id            = aws_security_group.ecs_task_security_group.id
  ip_protocol                  = "tcp"
  from_port                    = "80"
  to_port                      = "80"
  referenced_security_group_id = aws_security_group.alb_security_group.id
}

resource "aws_vpc_security_group_egress_rule" "allows_access_to_all_internet" {
  security_group_id = aws_security_group.ecs_task_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
