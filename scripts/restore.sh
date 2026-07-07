#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <backup-file>  (e.g. backups/hotel_bookings_20260707_120000.dump)"
  exit 1
fi
BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

POSTGRES_USER="${POSTGRES_USER:-app_admin}"
POSTGRES_DB="${POSTGRES_DB:-hotel_bookings}"
RESTORE_DB="${POSTGRES_DB}_restore_verify"

if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose)
else
  echo "Error: neither 'docker compose' (plugin) nor 'docker-compose' (standalone) was found." >&2
  exit 1
fi

echo "Restoring into a fresh database: $RESTORE_DB"
"${COMPOSE[@]}" exec -T db psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS ${RESTORE_DB};"
"${COMPOSE[@]}" exec -T db psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE ${RESTORE_DB};"
"${COMPOSE[@]}" exec -T db pg_restore -U "$POSTGRES_USER" -d "$RESTORE_DB" --no-owner < "$BACKUP_FILE"

echo
echo "Restore complete. Verify with:"
echo "  ${COMPOSE[*]} exec db psql -U $POSTGRES_USER -d $RESTORE_DB -c '\\dt'"
echo "  ${COMPOSE[*]} exec db psql -U $POSTGRES_USER -d $RESTORE_DB -c 'SELECT COUNT(*) FROM hotel_bookings;'"
