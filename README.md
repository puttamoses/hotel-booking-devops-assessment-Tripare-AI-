# Hotel Booking DevOps Assessment

Terraform AWS infra (`ALB → ECS/Fargate → RDS`) plus a local Postgres setup
with seed data, an optimized query, and backup/restore scripts.

## Structure

```
infra/
  modules/       network, ecs, rds
  envs/          dev, prod
db/migrations/   schema, seed data, indexes
scripts/         backup.sh, restore.sh
.github/workflows/terraform.yml
```

## Terraform

```bash
cd infra/envs/dev   # or prod

terraform fmt -check -recursive ../..
terraform init
terraform validate

cp terraform.tfvars.example terraform.tfvars
export TF_VAR_db_password="<password>"
terraform plan -refresh=false
```

dev and prod differ in instance size, backup retention, deletion
protection, and multi-AZ (see `terraform.tfvars.example` in each).

## Local database

```bash
cp .env.example .env
docker compose up -d
docker compose ps   # wait for "healthy"
```

Migrations in `db/migrations/` run automatically on first boot: schema,
seed data (120 bookings), and an index for the city + recency query in
`003_add_indexes.sql`.

```bash
docker compose exec db psql -U app_admin -d hotel_bookings -c '\dt'
```

## Backup / restore

```bash
./scripts/backup.sh
./scripts/restore.sh                          # restores the most recent backup
./scripts/restore.sh backups/<file>.dump      # or restore a specific one
```

`restore.sh` restores into a separate `_restore_verify` database, so it
never touches the live one. Verify:

```bash
docker compose exec db psql -U app_admin -d hotel_bookings_restore_verify -c '\dt'
docker compose exec db psql -U app_admin -d hotel_bookings_restore_verify -c 'SELECT COUNT(*) FROM hotel_bookings;'
```

## CI

`.github/workflows/terraform.yml` runs `fmt`/`init`/`validate`/`plan` for
both environments on pull requests and posts the plan as a PR comment.
Works without AWS credentials by default; add repo secrets
`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` to plan against a real account.
