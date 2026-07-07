# hotel-booking-devops-assessment-Tripare-AI-

Terraform AWS infrastructure: `Internet → ALB → ECS/Fargate → RDS`.

## Structure

```
infra/
  modules/
    network/   VPC, public/private subnets, IGW, NAT, security groups, ALB
    ecs/       ECS cluster, task definition, service, IAM roles
    rds/       DB subnet group + RDS instance
  envs/
    dev/       small instance, 3-day backups, deletion protection off
    prod/      bigger instance, 14-day backups, deletion protection on, multi-AZ
```

## Dev vs prod

| Setting | dev | prod |
|---|---|---|
| RDS instance class | `db.t3.micro` | `db.t3.medium` |
| RDS backup retention | 3 days | 14 days |
| RDS deletion protection | off | on |
| RDS multi-AZ | off | on |
| ECS desired count | 1 | 2 |
| ECS task CPU/memory | 256 / 512 | 512 / 1024 |
| VPC CIDR | `10.0.0.0/16` | `10.1.0.0/16` |

Each environment uses a local Terraform state file by default
(`envs/dev/dev.tfstate`, `envs/prod/prod.tfstate`); swap in the commented
`backend "s3"` block in `versions.tf` for remote state.

## Usage

```bash
cd infra/envs/dev   # or infra/envs/prod

terraform fmt -check -recursive ../..
terraform init
terraform validate

cp terraform.tfvars.example terraform.tfvars
export TF_VAR_db_password="<password>"
terraform plan -refresh=false
```

`db_engine_version` is major-version-only (e.g. `"16"`) with
`auto_minor_version_upgrade = true`, since RDS periodically retires specific
minor versions.

RDS is private (`publicly_accessible = false`), reachable only from the ECS
security group; ECS is reachable only from the ALB; the ALB is the only
public entrypoint.

## CI

`.github/workflows/terraform.yml` runs on pull requests touching `infra/**`:
`fmt` → `init` → `validate` → `plan` for both `dev` and `prod`, with each
plan posted as a PR comment. No real AWS account is required — the job uses
placeholder credentials plus `skip_aws_account_lookup = true`, which skips
the AWS provider's account/credential checks so plans render without cloud
access. Set repo secrets `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` to
plan against a real account instead.
