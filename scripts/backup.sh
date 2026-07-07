#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_USER="${POSTGRES_USER:-app_admin}"
POSTGRES_DB="${POSTGRES_DB:-hotel_bookings}"

mkdir -p backups
timestamp=$(date +%Y%m%d_%H%M%S)
out="backups/${POSTGRES_DB}_${timestamp}.dump"

docker compose exec -T db pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -F c > "$out"

echo "Backup written to $out"
