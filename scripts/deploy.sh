#!/usr/bin/env bash
# Self-hosting deployment helper for دليل النبك.
# Run from the repository root: ./scripts/deploy.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "ERROR: .env is missing." >&2
  echo "Copy artifacts/nabk-directory/.env.example to ./.env and fill in the values, then re-run." >&2
  exit 1
fi

set -a; source .env; set +a

COMPOSE_FILE="docker-compose.prod.yml"

echo "→ Pulling latest images..."
docker compose -f "$COMPOSE_FILE" pull

echo "→ Building app image..."
docker compose -f "$COMPOSE_FILE" build

echo "→ Starting services..."
docker compose -f "$COMPOSE_FILE" up -d

echo "→ Waiting for database..."
sleep 5

echo "→ Applying database migrations..."
# Prisma CLI is bundled into the runner image (see Dockerfile),
# so we run it through the resolved bin path.
docker compose -f "$COMPOSE_FILE" exec -T app sh -c \
  "cd artifacts/nabk-directory && /app/node_modules/.bin/prisma migrate deploy --schema=prisma/schema.prisma"

echo "→ Done. App is available at \${NEXT_PUBLIC_APP_URL}."
echo "  Health check: curl http://localhost/api/health"
