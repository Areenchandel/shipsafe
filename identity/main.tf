data "aws_caller_identity" "current" {}
data "aws_ssoadmin_instances" "this" {}

data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket  = "shipsafe-tfstate-190335339393"
    key     = "org/terraform.tfstate"
    region  = "ap-south-1"
    profile = "shipsafe-mgmt"
  }
}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  accounts = merge(
    data.terraform_remote_state.org.outputs.account_ids,
    { mgmt = data.aws_caller_identity.current.account_id }
  )
}

resource "aws_identitystore_user" "areen" {
  identity_store_id = local.identity_store_id
  user_name         = "areen"
  display_name      = "Areen Chandel"

  name {
    given_name  = "Areen"
    family_name = "Chandel"
  }

  emails {
    value   = "areenchandel0111+sso@gmail.com"
    primary = true
  }
}

resource "aws_identitystore_group" "this" {
  for_each          = toset(["admins", "developers"])
  identity_store_id = local.identity_store_id
  display_name      = each.key
}

resource "aws_identitystore_group_membership" "areen" {
  for_each          = aws_identitystore_group.this
  identity_store_id = local.identity_store_id
  group_id          = each.value.group_id
  member_id         = aws_identitystore_user.areen.user_id
}

locals {
  permission_sets = {
    AdminAccess     = "arn:aws:iam::aws:policy/AdministratorAccess"
    DeveloperAccess = "arn:aws:iam::aws:policy/PowerUserAccess"
    ReadOnly        = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = local.permission_sets
  name             = each.key
  instance_arn     = local.instance_arn
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.permission_sets
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  managed_policy_arn = each.value
}

locals {
  assignments = merge(
    { for k, id in local.accounts : "admins-${k}" => { group = "admins", ps = "AdminAccess", account = id } },
    {
      "developers-dev"     = { group = "developers", ps = "DeveloperAccess", account = local.accounts.dev }
      "developers-staging" = { group = "developers", ps = "ReadOnly", account = local.accounts.staging }
      "developers-prod"    = { group = "developers", ps = "ReadOnly", account = local.accounts.prod }
    }
  )
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = local.assignments
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.ps].arn
  principal_id       = aws_identitystore_group.this[each.value.group].group_id
  principal_type     = "GROUP"
  target_id          = each.value.account
  target_type        = "AWS_ACCOUNT"

  depends_on = [aws_ssoadmin_managed_policy_attachment.this]
}

output "sso_start_url" {
  value = "https://${local.identity_store_id}.awsapps.com/start"
}
