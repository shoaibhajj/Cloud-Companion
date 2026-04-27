#!/bin/bash
set -e

# Install all workspace dependencies (no lockfile pinning so freshly added
# devDependencies — e.g. @playwright/test from task #8 — install cleanly).
pnpm install

# Apply any pending Prisma migrations for the Nabk directory app and
# regenerate the Prisma client so the app's TypeScript matches the DB.
# `migrate deploy` is the non-interactive, production-safe command (no
# prompts, no destructive `db push`). It's a no-op when nothing is pending.
pnpm --filter @workspace/nabk-directory exec prisma migrate deploy
pnpm --filter @workspace/nabk-directory exec prisma generate
