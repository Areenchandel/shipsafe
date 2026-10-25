# ShipSafe - Test Results

## Week 1: Organization & SCP guardrails (2026-10-25)

Org `o-an65zvadtp`: 6 accounts in 3 OUs (Security, Workloads/NonProd, Workloads/Prod).

| # | Test | Command | Result |
|---|------|---------|--------|
| 1a | Blocked region | `aws ec2 describe-instances --region us-west-2 --profile shipsafe-dev` | UnauthorizedOperation: explicit deny in SCP `deny-regions` |
| 1b | Allowed region | `aws ec2 describe-instances --region ap-south-1 --profile shipsafe-dev` | Success |
| 1c | IAM user in Prod | `aws iam create-user --user-name scp-test --profile shipsafe-prod` | AccessDenied: explicit deny in SCP `prod-deny-iam-users` |
| 1d | IAM in Dev | `aws iam get-account-summary --profile shipsafe-dev` | Success (0 users) |

## Week 2: Identity & keyless CI access (2026-10-25)

| # | Test | Result |
|---|------|--------|
| 2a | SSO login (`aws sso login`) | AdminAccess via IAM Identity Center, 4h sessions |
| 2b | Static access key removed | `bootstrap-admin` deleted (NoSuchEntity) |
| 2c | Deploy-role trust | dev/staging/prod `shipsafe-deploy` trust only `shipsafe-github-actions` |
| 2d | GitHub OIDC -> mgmt -> dev/staging/prod | oidc-test run #3: 3/3 jobs green in 18s, zero stored secrets |

Note: GitHub OIDC `sub` uses the ID-qualified form `repo:Areenchandel@179294400/shipsafe@1432957677:...`; trust policy pins owner+repo IDs (resists repo rename/re-creation).
