# ShipSafe - Test Results

## Week 1: Organization & SCP guardrails (2026-10-25)

Org `o-an65zvadtp`: 6 accounts in 3 OUs (Security, Workloads/NonProd, Workloads/Prod).

| # | Test | Command | Result |
|---|------|---------|--------|
| 1a | Blocked region | `aws ec2 describe-instances --region us-west-2 --profile shipsafe-dev` | UnauthorizedOperation: explicit deny in SCP `deny-regions` |
| 1b | Allowed region | `aws ec2 describe-instances --region ap-south-1 --profile shipsafe-dev` | Success |
| 1c | IAM user in Prod | `aws iam create-user --user-name scp-test --profile shipsafe-prod` | AccessDenied: explicit deny in SCP `prod-deny-iam-users` |
| 1d | IAM in Dev | `aws iam get-account-summary --profile shipsafe-dev` | Success (0 users) |
