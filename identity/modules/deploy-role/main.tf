terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "github_role_arn" {
  type = string
}

resource "aws_iam_role" "deploy" {
  name                 = "shipsafe-deploy"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = var.github_role_arn }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "arn" {
  value = aws_iam_role.deploy.arn
}
