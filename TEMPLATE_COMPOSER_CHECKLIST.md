# Railway Template Composer Checklist — Evolution API

Apply these settings in the Railway template composer when generating the template from the project.

---

## 1. Healthcheck Settings

### evolution-api
- **Healthcheck Path:** `/`
- **Healthcheck Timeout:** `120` seconds
- **Variable:** `RAILWAY_HEALTHCHECK_PATH` = `/` with description

### postgres / redis
- No public port exposed — no healthcheck needed (internal services only)

---

## 2. Variable Descriptions (Add to EVERY variable)

### evolution-api Variables

**Real, CLI-verified list (`railway variables --service evolution-api-railway`, re-checked 2026-07-22) — these 8 are the actual variables that will show up in the composer's "evolution-api" service card, nothing more, nothing less:**

| Variable | Value (currently set — this exact string, verified via CLI) | Mark Optional? | Description |
|----------|----------------------------------------------------------------|-----------------|-------------|
| `DATABASE_PROVIDER` | `postgresql` | No | Database driver Evolution API uses. |
| `DATABASE_CONNECTION_URI` | `${{Postgres.DATABASE_URL}}` | No | Postgres connection string. Auto-set from the Postgres service. |
| `CACHE_REDIS_ENABLED` | `true` | No | Enables Redis caching for connection state. |
| `CACHE_REDIS_URI` | `${{Redis.REDIS_URL}}` | No | Redis connection string. Auto-set from the Redis service. |
| `SERVER_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | No | Public URL for webhook callbacks and QR metadata. |
| `AUTHENTICATION_API_KEY` | **Currently a literal test key (`8cc21b80...`), NOT the secret() syntax below — you must manually replace it with `${{secret(64, "abcdef0123456789")}}` in the composer, or every future deployer gets this exact same hardcoded key** | No | Global API key required in the `apikey` header on every request. Auto-generated. |
| `LANGUAGE` | `en` | **Yes** — this is a cosmetic default, not required for the app to function | Default language for instance-facing messages. |
| `RAILWAY_HEALTHCHECK_PATH` | `/` | No | Endpoint Railway uses to verify the service is healthy. |

**Correction on an earlier version of this table:** it listed `PORT` / `SERVER_PORT` as if it were a composer variable — **it is not.** As of the 2026-07-25 `/manager` redirect fix (see section 6 below), the real port scheme is `API_INTERNAL_PORT=8081` (the actual Evolution API process, internal-only) and `WRAPPER_PORT=8080` (the redirect/proxy wrapper that's actually public-facing) — both are build-time `ENV` instructions in the Dockerfile, invisible to `railway variable set`/the composer's Variables panel entirely; you will not see or need to set either there. It also previously listed `RAILWAY_HEALTHCHECK_PATH` as already set — it genuinely wasn't (confirmed via CLI it was missing), so it was added via `railway variable set RAILWAY_HEALTHCHECK_PATH=/`, and all 8 rows above are verified directly against a fresh `railway variables` dump rather than reused from memory.

### Postgres Variables (this template uses Railway's managed Postgres plugin — `railwayapp-templates/postgres-ssl`, added via `railway add --database postgres`, NOT a custom Docker service. All 13 of these appear in the composer's "Postgres" service card and each needs a description. "Value" = what's already in the Variable Value field, or what to type in if it's showing empty. "Mark Optional?" = whether to check the "Mark as optional" checkbox, per SKILL.md's rule: any variable you're giving an explicit default to should be optional so Railway can still let a deployer override it.)

| Variable | Value (already prefilled by Railway, or what to set) | Mark Optional? | Description |
|----------|-------------------------------------------------------|-----------------|-------------|
| `DATABASE_URL` | Already auto-set by Railway (private connection string) — leave as is | No | The primary database connection string, over Railway's private network. Auto-set. |
| `DATABASE_PUBLIC_URL` | Already auto-set by Railway (public connection string) — leave as is | No | Public database connection string for external access outside Railway. Auto-set. |
| `PGDATA` | `/var/lib/postgresql/data/pgdata` | **Yes** | Directory where Postgres stores its data files inside the container. |
| `PGHOST` | Already prefilled: `${{RAILWAY_PRIVATE_DOMAIN}}` — leave as is | No | Internal hostname for the Postgres database service. |
| `PGPORT` | Shows "Empty value to be filled by the user" — set to `5432` | **Yes** | Port the Postgres database listens on. |
| `PGUSER` | Already prefilled: `${{POSTGRES_USER}}` — leave as is | No | Username for connecting to the Postgres database. |
| `PGPASSWORD` | **Not screenshot-confirmed** — inferred by pattern from `PGUSER`→`${{POSTGRES_USER}}` and `PGDATABASE`→`${{POSTGRES_DB}}`, so likely `${{POSTGRES_PASSWORD}}`, but verify what's actually shown before trusting this (this is the same category of field — a secret — where I got `POSTGRES_PASSWORD` wrong earlier) | No | Password for connecting to the Postgres database. Auto-generated. |
| `PGDATABASE` | Already prefilled: `${{POSTGRES_DB}}` — leave as is | No | Default database name created in Postgres. |
| `POSTGRES_USER` | `postgres` | **Yes** | Username for the Postgres superuser account. |
| `POSTGRES_PASSWORD` | Already prefilled by Railway: `${{secret(32, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")}}` — leave as is (confirmed live in the composer 2026-07-22; my earlier `${{secret(16)}}` guess in this doc was wrong and has been corrected) | No | Password for the Postgres superuser. Auto-generated. |
| `POSTGRES_DB` | `railway` | **Yes** | Default database name created on startup (same value as `PGDATABASE`). |
| `SSL_CERT_DAYS` | `820` | **Yes** | Number of days the auto-generated SSL certificate stays valid. |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `60` | **Yes** | Seconds Railway waits for active connections to finish before a redeploy. |

The six marked **Yes** above (`PGDATA`, `PGPORT`, `POSTGRES_DB`, `POSTGRES_USER`, `SSL_CERT_DAYS`, `RAILWAY_DEPLOYMENT_DRAINING_SECONDS`) are the same six SKILL.md flags project-wide as needing an explicit default + optional flag — this isn't specific to Evolution API, every template in this project follows the same six.

### Redis Variables (managed Redis plugin, added via `railway add --database redis`)

| Variable | Value (already prefilled by Railway, or what to set) | Mark Optional? | Description |
|----------|-------------------------------------------------------|-----------------|-------------|
| `REDIS_URL` | Already auto-set by Railway (private connection string) — leave as is | No | Redis connection string over Railway's private network. Auto-set. Used by `CACHE_REDIS_URI` on the app service. |
| `REDIS_PUBLIC_URL` | Already auto-set by Railway (public connection string) — leave as is | No | Public Redis connection string for external access outside Railway. Auto-set. |
| `REDISHOST` | **Not screenshot-confirmed** — inferred by pattern from `PGHOST`, so likely `${{RAILWAY_PRIVATE_DOMAIN}}`, but I never saw the Redis service's Variables panel — verify before trusting | No (unless shown empty) | Internal hostname for the Redis service. |
| `REDISPORT` | Unconfirmed — check what's actually showing in the composer before touching it. If empty, `6379` is the real value (confirmed via `railway variables --service Redis`). | Only if actually empty | Port the Redis service listens on. |
| `REDISUSER` | Unconfirmed — check what's actually showing in the composer before touching it. If empty, `default` is the real value (confirmed via `railway variables --service Redis`). | Only if actually empty | Username for connecting to Redis. |
| `REDISPASSWORD` / `REDIS_PASSWORD` | **Not screenshot-confirmed** — presumably auto-generated like `POSTGRES_PASSWORD` was, but I haven't seen the actual value/syntax shown in the composer for this one either — verify before trusting | No (unless shown empty) | Password for connecting to Redis. Auto-generated. |

**Important caveat on this whole Redis table: I have never actually seen a screenshot of the Redis service's Variables panel in the composer** (only Postgres's, and only the app service's variable count, not its panel). Every "leave as is" / prefilled-value claim here beyond `REDISPORT`/`REDISUSER` (which came from real `railway variables --service Redis` CLI output) is inference by pattern-matching against the Postgres panel, not direct confirmation — treat this whole table as lower-confidence than the Postgres one until you open that panel and I can see what's actually there.

---

## 3. Auto-Injected Variables — Default Values

If using Railway's managed Postgres plugin, set defaults so users don't get "needs configuration" prompts:

| Variable | Default Value | Mark Optional? |
|----------|---------------|-----------------|
| `PGDATA` | `/var/lib/postgresql/data/pgdata` | Yes |
| `PGPORT` | `5432` | Yes |
| `POSTGRES_DB` | `railway` | Yes |
| `POSTGRES_USER` | `postgres` | Yes |
| `SSL_CERT_DAYS` | `820` | Yes |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `60` | Yes |

---

## 4. Secrets That Must Use `${{secret()}}`

**NEVER** hardcode real credentials from the dev project.

| Variable | Template Syntax |
|----------|-----------------|
| `AUTHENTICATION_API_KEY` | `${{secret(64, "abcdef0123456789")}}` |
| `POSTGRES_PASSWORD` (if Docker postgres) | `${{secret(16)}}` |
| `REDIS_PASSWORD` (if Docker redis with auth) | `${{secret(16)}}` |

---

## 5. Volume

- **Mount path:** `/evolution/instances`
- **Attached to:** `evolution-api` service only
- Do **not** add a Docker `VOLUME` instruction to the Dockerfile — Railway's builder rejects it. Persistence must go through Railway Volumes (CLI/dashboard) exclusively.

---

## 6. Known Troubleshooting

- **Root `/` now redirects to `/manager` (fixed 2026-07-25) — was previously a real, flagged UX gap.** Originally, hitting the bare root returned raw welcome JSON with a `"manager"` field pointing at `/manager`, and most deployers had no reason to know to append that path manually (Shruti caught this directly: *"are you sure the developer will know that they have to put /manager in the URL to make it work?"*). Checked Evolution API's own source and docs — confirmed no built-in redirect config exists, so this needed an actual code fix, not a variable/composer change. Fixed via a small reverse-proxy wrapper (`wrapper/proxy.js`, using the `http-proxy` npm package) that listens on the real public port, 302-redirects a bare `GET`/`HEAD /` to `/manager`, and transparently proxies everything else — including WebSocket upgrades — to the real Evolution API process running on an internal-only port. **Verified live, not just deployed:** `curl` confirmed `/` → real `302` to `/manager`, `/manager` still serves the genuine "Evolution Manager" SPA (`200` after following its own internal `/manager` → `/manager/` redirect), an unauthenticated protected API endpoint still correctly returns `401` (proxy doesn't bypass auth), and a real Playwright browser load landed cleanly on the manager's login screen with no relevant console errors (the one 404 seen is an unrelated external asset on `evolution-api.com`'s own CDN, not anything served through this template). **Since this app service is GitHub-connected, this fix required no template regeneration** — pushing to `shruti060701/evolution-api-railway`'s default branch was enough; any already-published template referencing this same repo picks up the fix automatically on its next build.
- **If the wrapper itself seems broken** (root doesn't redirect, or the whole service is unreachable): check `railway logs --deployment` for two expected lines — `HTTP - ON: 8081` (the real API, confirmed bound to the internal port) and `[wrapper] listening on 8080, proxying to http://127.0.0.1:8081, redirecting / to /manager` (the wrapper itself). If either is missing, that process didn't start — check the same logs further up for a crash/error from that specific process.
- **Built-in manager UI confirmed live at `/manager`** (originally verified 2026-07-22 via real deploy). This ships inside `evoapicloud/evolution-api` itself — no separate `evolution-manager` service needed. Worth calling out in the template's marketing copy as a real differentiator against competing templates that are API-only.
- **Direct API calls to any other path still work exactly as before** — the redirect only special-cases a bare `GET`/`HEAD /`; every other path (including `POST /instance/create`, webhooks, etc.) passes through the wrapper untouched.
- **QR code expired:** QR codes expire quickly (Baileys default). If a scan attempt fails, re-fetch the QR via the instance's connect endpoint rather than reusing an old one.
- **Volume permission errors:** only apply a `USER root` / `gosu`-drop-privileges fix if an actual `EACCES` error is observed in `railway logs` after a real deploy — do not preemptively add one from static Dockerfile inspection (see project memory: this exact mistake was made and reverted on Uptime Kuma).
- **Redis/Postgres not ready on first boot:** if the API crash-loops immediately after deploy, check `railway logs --deployment --latest` for a connection-refused error — Postgres/Redis services can take a few seconds longer to come up than the API container on a fresh multi-service deploy.

---

## 7. Post-Deploy Steps

After the template is published, test-deploy from a fresh Railway account (incognito window) to verify:

1. No "needs configuration" prompts appear for Postgres/Redis auto-injected variables.
2. All 3 services come online within a few minutes.
3. The root URL (`/`) returns a `302` redirect to `/manager`, which itself loads the real Evolution Manager login screen (`200` after its own internal `/manager` → `/manager/` redirect) — not a JSON welcome payload directly at `/`.
4. Creating an instance via `POST /instance/create` (with the `apikey` header) returns a QR code, and scanning it from WhatsApp's Linked Devices menu connects successfully.
