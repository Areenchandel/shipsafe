locals {
  scps = {
    deny-regions        = { file = "deny-regions.json", target = local.root_id, desc = "Allow only ap-south-1 and us-east-1" }
    baseline-guardrails = { file = "baseline-guardrails.json", target = local.root_id, desc = "No leaving org, no root user, protect security services" }
    prod-deny-iam-users = { file = "prod-deny-iam-users.json", target = aws_organizations_organizational_unit.prod.id, desc = "No IAM users or access keys in prod" }
  }
}

resource "aws_organizations_policy" "scp" {
  for_each    = local.scps
  name        = each.key
  description = each.value.desc
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode(jsondecode(file("${path.module}/policies/${each.value.file}")))
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each  = local.scps
  policy_id = aws_organizations_policy.scp[each.key].id
  target_id = each.value.target
}
