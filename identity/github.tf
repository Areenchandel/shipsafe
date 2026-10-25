locals {
  github_repo = "Areenchandel@179294400/shipsafe@1432957677"
  deploy_envs = ["dev", "staging", "prod"]
  state_arn   = "arn:aws:s3:::shipsafe-tfstate-190335339393"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.github_repo}:ref:refs/heads/main",
        "repo:${local.github_repo}:pull_request",
        "repo:${local.github_repo}:environment:*",
      ]
    }
  }
}

resource "aws_iam_role" "github" {
  name                 = "shipsafe-github-actions"
  assume_role_policy   = data.aws_iam_policy_document.github_trust.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "github_perms" {
  statement {
    sid       = "AssumeDeployRoles"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = [for e in local.deploy_envs : "arn:aws:iam::${local.accounts[e]}:role/shipsafe-deploy"]
  }

  statement {
    sid       = "StateBucketList"
    actions   = ["s3:ListBucket"]
    resources = [local.state_arn]
  }

  statement {
    sid       = "StateObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${local.state_arn}/*"]
  }
}

resource "aws_iam_role_policy" "github" {
  name   = "assume-deploy-and-state"
  role   = aws_iam_role.github.id
  policy = data.aws_iam_policy_document.github_perms.json
}

module "deploy_dev" {
  source          = "./modules/deploy-role"
  github_role_arn = aws_iam_role.github.arn
  providers       = { aws = aws.dev }
}

module "deploy_staging" {
  source          = "./modules/deploy-role"
  github_role_arn = aws_iam_role.github.arn
  providers       = { aws = aws.staging }
}

module "deploy_prod" {
  source          = "./modules/deploy-role"
  github_role_arn = aws_iam_role.github.arn
  providers       = { aws = aws.prod }
}

output "github_role_arn" {
  value = aws_iam_role.github.arn
}

output "deploy_role_arns" {
  value = {
    dev     = module.deploy_dev.arn
    staging = module.deploy_staging.arn
    prod    = module.deploy_prod.arn
  }
}
