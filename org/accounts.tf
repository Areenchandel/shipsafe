locals {
  email_user   = "areenchandel0111"
  email_domain = "gmail.com"

  accounts = {
    security   = { name = "shipsafe-security", ou = aws_organizations_organizational_unit.security.id }
    logarchive = { name = "shipsafe-logarchive", ou = aws_organizations_organizational_unit.security.id }
    dev        = { name = "shipsafe-dev", ou = aws_organizations_organizational_unit.nonprod.id }
    staging    = { name = "shipsafe-staging", ou = aws_organizations_organizational_unit.nonprod.id }
    prod       = { name = "shipsafe-prod", ou = aws_organizations_organizational_unit.prod.id }
  }
}

resource "aws_organizations_account" "this" {
  for_each = local.accounts

  name                       = each.value.name
  email                      = "${local.email_user}+shipsafe-${each.key}@${local.email_domain}"
  parent_id                  = each.value.ou
  role_name                  = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "DENY"
  close_on_deletion          = false

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [role_name, iam_user_access_to_billing]
  }
}

output "account_ids" {
  value = { for k, a in aws_organizations_account.this : k => a.id }
}
