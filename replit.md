# Workspace

## Overview

pnpm workspace monorepo using TypeScript. Each package manages its own dependencies.

## Stack

- **Monorepo tool**: pnpm workspaces
- **Node.js version**: 24
- **Package manager**: pnpm
- **TypeScript version**: 5.9
- **API framework**: Express 5
- **Database**: PostgreSQL + Drizzle ORM
- **Validation**: Zod (`zod/v4`), `drizzle-zod`
- **API codegen**: Orval (from OpenAPI spec)
- **Build**: esbuild (CJS bundle)

## Key Commands

- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- `pnpm --filter @workspace/api-server run dev` — run API server locally

See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details.

## Artifacts

### `artifacts/nabk-directory` — دليل النبك

Arabic-first (RTL) city business directory for النبك, Syria.

- **Stack**: Next.js 16 App Router (TypeScript strict, `output: standalone`), Tailwind v4, Prisma 6 (NEVER v7), PostgreSQL, NextAuth v5 beta (**JWT** sessions — Auth.js v5 forbids Credentials with database sessions; Prisma adapter still wired for OAuth and user storage), Resend, sharp.
- **Artifact**: registered as a `web` kind via `.replit-artifact/artifact.toml`, served at `/` (root). Auto-generated workflow `artifacts/nabk-directory: Web` runs `pnpm exec next dev --port 5000 --hostname 0.0.0.0`.
- **Database**: workspace Postgres via `DATABASE_URL`. Schema pushed via `pnpm exec prisma db push`. Seeded with city النبك, 10 categories, 6 demo businesses, an admin (`admin@nabk.local` / `Admin123!`), and an owner (`owner@nabk.local` / `Owner123!`). NextAuth tables follow the canonical adapter names (`Account`, `Session`) with custom `@@map` to keep snake_case tables.
- **Auth**: AUTH_SECRET / NEXTAUTH_SECRET set via shared env. JWT callback re-fetches role and `deletedAt` at most once per minute and revokes the session if the user is soft-deleted, so role/disabled changes propagate within ~60s without losing the Credentials provider.
- **Self-hosting**: Dockerfile (multi-stage standalone), docker-compose.yml, nginx.conf, deploy.sh, and .env.example all live in the artifact directory. Build context is the repo root. `deploy.sh` uses `prisma db push` (no migration history yet — switch to `prisma migrate deploy` once formal migrations are adopted).
- **Status (MVP)**: homepage, browse + search, category landing, business detail with working hours and "open now" pill, sign-in / sign-up / sign-out, owner dashboard skeleton, public `/api/health` endpoint. Listing-creation wizard, ratings/comments submission, admin panel, image uploads, and notification triggers are scaffolded (lib/storage, lib/audit, lib/rate-limit) but not yet wired — these are the planned follow-ups.
- **Notes**: next-intl was removed in favor of inline Arabic strings (no runtime translation needed for an Arabic-only site, and v3 was not compatible with Turbopack 16).
