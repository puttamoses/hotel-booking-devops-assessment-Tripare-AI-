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

## Local database (Part 4)

```bash
cp .env.example .env
docker compose up -d
docker compose ps        # wait for "healthy"
```

Postgres 16 starts on `localhost:5432` (override via `.env`). On first boot,
Postgres auto-runs everything in `db/migrations/` in filename order — right
now that's `001_create_tables.sql`, creating `hotel_bookings` and
`booking_events` (with `booking_events.booking_id` as a foreign key into
`hotel_bookings.id`).

Verify:

```bash
docker compose exec db psql -U app_admin -d hotel_bookings -c '\dt'
```

To re-run migrations from scratch: `docker compose down -v` (drops the data
volume) then `docker compose up -d` again.

## Seed data and indexing (Part 5)

`db/migrations/002_seed_data.sql` inserts 120 deterministic bookings across
5 cities, 4 orgs, and 4 statuses, plus `booking_events` rows for a subset —
all applied automatically on `docker compose up -d` alongside the schema.

Optimized query:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Index added in `db/migrations/003_add_indexes.sql`:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
  ON hotel_bookings (city, created_at)
  INCLUDE (org_id, status, amount);
```

`city` leads the key (equality filter), `created_at` follows (range filter)
— together they turn the WHERE clause into a single index range scan
instead of a full table scan. `org_id`, `status`, `amount` are added via
`INCLUDE` rather than as key columns, since they're only needed for the
`GROUP BY`/aggregation, not for filtering or sorting — this lets Postgres
answer the query as an index-only scan without hitting the heap.

## Backup and restore (Part 6)

```bash
./scripts/backup.sh                          # writes backups/<db>_<timestamp>.dump
./scripts/restore.sh backups/<file>.dump      # restores into a fresh <db>_restore_verify database
```

`restore.sh` never touches the live database — it drops/recreates a
separate `*_restore_verify` database and restores into that, so you can
verify without risking the working copy. Verify the restore worked:

```bash
docker compose exec db psql -U app_admin -d hotel_bookings_restore_verify -c '\dt'
docker compose exec db psql -U app_admin -d hotel_bookings_restore_verify -c 'SELECT COUNT(*) FROM hotel_bookings;'
```

Expect `\dt` to list both tables and the count to match the source database
(120 seeded rows, or more if you've inserted your own data since).

## CI

`.github/workflows/terraform.yml` runs on pull requests touching `infra/**`:
`fmt` → `init` → `validate` → `plan` for both `dev` and `prod`, with each
plan posted as a PR comment. No real AWS account is required — the job uses
placeholder credentials plus `skip_aws_account_lookup = true`, which skips
the AWS provider's account/credential checks so plans render without cloud
access. Set repo secrets `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` to
plan against a real account instead.
