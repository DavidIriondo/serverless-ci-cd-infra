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


//Secrets to store ECR arn
resource "aws_secretsmanager_secret" "frontend_ecr_arn" {
  name = "scc-ecr-front-secret"
}

resource "aws_secretsmanager_secret_version" "ecr_front" {
  secret_id     = aws_secretsmanager_secret.frontend_ecr_arn.id
  secret_string = jsonencode(var.ecr_arn)
}
