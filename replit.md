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
- **Self-hosting**: `artifacts/nabk-directory/Dockerfile` (multi-stage standalone) plus root-level `docker-compose.prod.yml`, `nginx/nabk.conf`, `scripts/deploy.sh`, `.dockerignore`, and `artifacts/nabk-directory/.env.example`. Build context = repo root. Baseline Prisma migration committed at `prisma/migrations/0_init/migration.sql`; `scripts/deploy.sh` runs `prisma migrate deploy` against the running container.
- **Auth flows**: Sign-up creates the user, sends a verification email via Resend (no-op if `RESEND_API_KEY` unset), and redirects to `/verify-email?sent=1` (NEVER auto-signs-in — eliminates the credentials/JWT mismatch). Pages: `/sign-in`, `/sign-up`, `/verify-email` (server component invokes `verifyEmailAction(token)`), `/forgot-password`, `/reset-password?token=...`. Tokens are SHA-256 hashed at rest; password reset always returns `{sent:true}` to prevent enumeration. Rate-limiting via `withRateLimit()` on signup / signin / forgot. `/dashboard` enforces `auth() + emailVerified` in the server component (Auth.js v5 JWT decode is not edge-safe with our prisma-using callback, so `src/middleware.ts` is a pass-through reserved for future edge-safe checks).
- **Status (MVP)**: homepage, browse + search, category landing, business detail with working hours and "open now" pill, full email-verified auth (signup → verify → sign-in → dashboard → sign-out, plus forgot/reset), owner dashboard skeleton, public `/api/health` endpoint (no DB touch). Listing-creation wizard, ratings/comments submission, admin panel, image uploads, and notification triggers are scaffolded (lib/storage, lib/audit, lib/rate-limit) but not yet wired — these are the planned follow-ups.
- **Notes**: next-intl was removed in favor of inline Arabic strings (no runtime translation needed for an Arabic-only site, and v3 was not compatible with Turbopack 16). In Replit dev the api-server artifact owns `/api/*` so the public dev domain's `/api/health` hits that artifact instead — the Next.js health endpoint is reachable at `localhost:5000/api/health` and at the production domain (single-container Docker) where it is the sole `/api/*` owner.
