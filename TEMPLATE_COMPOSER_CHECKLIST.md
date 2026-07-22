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

| Variable | Description | Default / Reference |
|----------|-------------|---------------------|
| `PORT` / `SERVER_PORT` | The port Evolution API listens on. | `8080` |
| `RAILWAY_HEALTHCHECK_PATH` | Endpoint Railway uses to verify the service is healthy. | `/` |
| `DATABASE_PROVIDER` | Database driver Evolution API uses. | `postgresql` |
| `DATABASE_CONNECTION_URI` | Postgres connection string. Auto-set from the Postgres service. | `${{Postgres.DATABASE_URL}}` |
| `CACHE_REDIS_ENABLED` | Enables Redis caching for connection state. | `true` |
| `CACHE_REDIS_URI` | Redis connection string. Auto-set from the Redis service. | `${{Redis.REDIS_URL}}` |
| `SERVER_URL` | Public URL for webhook callbacks and QR metadata. | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| `AUTHENTICATION_API_KEY` | Global API key required in the `apikey` header on every request. Auto-generated. | `${{secret(64, "abcdef0123456789")}}` |
| `LANGUAGE` | Default language for instance-facing messages. | `en` |

### Postgres Variables (this template uses Railway's managed Postgres plugin — `railwayapp-templates/postgres-ssl`, added via `railway add --database postgres`, NOT a custom Docker service. All 13 of these appear in the composer's "Postgres" service card and each needs a description. "Value" = what's already in the Variable Value field, or what to type in if it's showing empty. "Mark Optional?" = whether to check the "Mark as optional" checkbox, per SKILL.md's rule: any variable you're giving an explicit default to should be optional so Railway can still let a deployer override it.)

| Variable | Value (already prefilled by Railway, or what to set) | Mark Optional? | Description |
|----------|-------------------------------------------------------|-----------------|-------------|
| `DATABASE_URL` | Already auto-set by Railway (private connection string) — leave as is | No | The primary database connection string, over Railway's private network. Auto-set. |
| `DATABASE_PUBLIC_URL` | Already auto-set by Railway (public connection string) — leave as is | No | Public database connection string for external access outside Railway. Auto-set. |
| `PGDATA` | `/var/lib/postgresql/data/pgdata` | **Yes** | Directory where Postgres stores its data files inside the container. |
| `PGHOST` | Already prefilled: `${{RAILWAY_PRIVATE_DOMAIN}}` — leave as is | No | Internal hostname for the Postgres database service. |
| `PGPORT` | Shows "Empty value to be filled by the user" — set to `5432` | **Yes** | Port the Postgres database listens on. |
| `PGUSER` | Already prefilled: `${{POSTGRES_USER}}` — leave as is | No | Username for connecting to the Postgres database. |
| `PGPASSWORD` | Already prefilled: `${{POSTGRES_PASSWORD}}` — leave as is | No | Password for connecting to the Postgres database. Auto-generated. |
| `PGDATABASE` | Already prefilled: `${{POSTGRES_DB}}` — leave as is | No | Default database name created in Postgres. |
| `POSTGRES_USER` | `postgres` | **Yes** | Username for the Postgres superuser account. |
| `POSTGRES_PASSWORD` | `${{secret(16)}}` (if showing empty) — otherwise already auto-generated | No | Password for the Postgres superuser. Auto-generated. |
| `POSTGRES_DB` | `railway` | **Yes** | Default database name created on startup (same value as `PGDATABASE`). |
| `SSL_CERT_DAYS` | `820` | **Yes** | Number of days the auto-generated SSL certificate stays valid. |
| `RAILWAY_DEPLOYMENT_DRAINING_SECONDS` | `60` | **Yes** | Seconds Railway waits for active connections to finish before a redeploy. |

The six marked **Yes** above (`PGDATA`, `PGPORT`, `POSTGRES_DB`, `POSTGRES_USER`, `SSL_CERT_DAYS`, `RAILWAY_DEPLOYMENT_DRAINING_SECONDS`) are the same six SKILL.md flags project-wide as needing an explicit default + optional flag — this isn't specific to Evolution API, every template in this project follows the same six.

### Redis Variables (managed Redis plugin, added via `railway add --database redis`)

| Variable | Value (already prefilled by Railway, or what to set) | Mark Optional? | Description |
|----------|-------------------------------------------------------|-----------------|-------------|
| `REDIS_URL` | Already auto-set by Railway (private connection string) — leave as is | No | Redis connection string over Railway's private network. Auto-set. Used by `CACHE_REDIS_URI` on the app service. |
| `REDIS_PUBLIC_URL` | Already auto-set by Railway (public connection string) — leave as is | No | Public Redis connection string for external access outside Railway. Auto-set. |
| `REDISHOST` | Already prefilled: `${{RAILWAY_PRIVATE_DOMAIN}}` — leave as is | No | Internal hostname for the Redis service. |
| `REDISPORT` | `6379` (if showing empty) | No — not in Railway's flagged auto-injected list; only mark optional if the composer actually shows it empty | Port the Redis service listens on. |
| `REDISUSER` | `default` | No — same as above, only if shown empty | Username for connecting to Redis. |
| `REDISPASSWORD` / `REDIS_PASSWORD` | Already auto-generated by Railway — leave as is | No | Password for connecting to Redis. Auto-generated. |

None of the Redis variables appeared in my earlier `railway variables --service Redis` dump as empty, so unlike Postgres's `PGPORT`, I don't have confirmed evidence any Redis variable needs "Mark as optional" — check live in the composer and only mark ones actually showing "Empty value to be filled by the user."

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

- **Built-in manager UI confirmed live at `/manager`** (verified 2026-07-22 via real deploy: root `/` welcome JSON includes a `"manager"` field pointing at it, and `curl` confirms a real "Evolution Manager" SPA is served, not a placeholder). This ships inside `evoapicloud/evolution-api` itself — no separate `evolution-manager` service needed. Worth calling out in the template's marketing copy as a real differentiator against competing templates that are API-only.
- **First-run without an instance:** hitting `/` returns a JSON welcome payload — this is expected and confirms the service is alive, not an error.
- **QR code expired:** QR codes expire quickly (Baileys default). If a scan attempt fails, re-fetch the QR via the instance's connect endpoint rather than reusing an old one.
- **Volume permission errors:** only apply a `USER root` / `gosu`-drop-privileges fix if an actual `EACCES` error is observed in `railway logs` after a real deploy — do not preemptively add one from static Dockerfile inspection (see project memory: this exact mistake was made and reverted on Uptime Kuma).
- **Redis/Postgres not ready on first boot:** if the API crash-loops immediately after deploy, check `railway logs --deployment --latest` for a connection-refused error — Postgres/Redis services can take a few seconds longer to come up than the API container on a fresh multi-service deploy.

---

## 7. Post-Deploy Steps

After the template is published, test-deploy from a fresh Railway account (incognito window) to verify:

1. No "needs configuration" prompts appear for Postgres/Redis auto-injected variables.
2. All 3 services come online within a few minutes.
3. The root URL (`/`) returns a 200 with a JSON welcome payload.
4. Creating an instance via `POST /instance/create` (with the `apikey` header) returns a QR code, and scanning it from WhatsApp's Linked Devices menu connects successfully.
