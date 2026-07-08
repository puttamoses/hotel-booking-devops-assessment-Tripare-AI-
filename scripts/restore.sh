#!/usr/bin/env bash
set -euo pipefail

ARG="${1:-}"
if [ -n "$ARG" ]; then
  case "$ARG" in
    /*) BACKUP_FILE="$ARG" ;;
    *) BACKUP_FILE="$(pwd)/$ARG" ;;
  esac
fi

cd "$(dirname "$0")/.."

if [ -z "${BACKUP_FILE:-}" ]; then
  BACKUP_FILE=$(ls -t backups/*.dump 2>/dev/null | head -n1 || true)
  if [ -z "$BACKUP_FILE" ]; then
    echo "No backup file given and none found in backups/. Run ./scripts/backup.sh first."
    echo "Usage: $0 [backup-file]  (e.g. backups/hotel_bookings_20260707_120000.dump)"
    exit 1
  fi
  echo "No backup file given, using most recent: $BACKUP_FILE"
fi

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
