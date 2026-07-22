## Template Titles

**Railway Title:** `Evolution API [Updated Jul '26]`
**Railway Description:** `Evolution API [Jul '26] (WhatsApp REST API, No Meta Approval) Self Host`
**Spreadsheet Title:** `Evolution API (Open-Source WhatsApp REST API & Automation Backend)`
**GitHub Description:** `Evolution API — open-source WhatsApp REST API built on Baileys. Deploy on Railway with one click.`

---

![Evolution API banner showing WhatsApp REST API dashboard](CLOUDINARY_URL "Hosting Evolution API on Railway")

# Deploy and Host self hosted Evolution API (Open-Source WhatsApp REST API) on Railway

Evolution API is an open-source WhatsApp REST API built on the Baileys library. It connects a real WhatsApp number over plain HTTP endpoints — no Meta Business API approval, no template review, no per-conversation billing. Create instances, scan a QR code, and start sending messages and receiving webhooks in minutes.

## About Hosting Evolution API open-source software on Railway (self hosted Evolution API template)

Self-hosting Evolution API means your message history, contacts, and API keys stay on infrastructure you control, not a third-party vendor's servers. Railway provisions PostgreSQL, Redis, and a persistent volume for WhatsApp session data automatically. You get HTTPS, private networking, and zero-downtime redeploys without touching a server yourself.

## Why Deploy Evolution API, the Meta WhatsApp Business API alternative on Railway (Railway Free Trial)

Meta's official WhatsApp Business API requires business verification, template approval for every message format, and per-conversation fees that scale with volume — often $0.02-0.10 depending on country. Evolution API connects like a normal WhatsApp session and charges nothing beyond hosting. Railway's $5 free trial covers your first month, and a typical deployment runs $10-20/month after that regardless of message volume.

### Railway vs Other Hosting Providers and VPS for Evolution API self hosting

| Provider          | What You Get with Railway                              | What You Get with the Other Provider                    |
| ----------------- | -------------------------------------------------------- | ----------------------------------------------------------- |
| **DigitalOcean**  | Managed Postgres/Redis, auto HTTPS, one-click deploy    | Raw droplet — install Docker, Postgres, Redis, Nginx yourself |
| **AWS**           | Simple usage-based billing, private networking built in | ECS/EC2 setup, security groups, IAM roles, ALB config    |
| **Hetzner**       | Zero-maintenance deploys with automatic restarts        | Cheap hardware, but you own OS patching and TLS renewal  |

## Common Use Cases for hosted Evolution API

- **Customer support automation** — Route incoming messages to a bot or helpdesk like Chatwoot without Meta's approval delays
- **Order and shipping notifications** — Send transactional updates from your e-commerce backend to customers' phones
- **Appointment reminders** — Clinics and service businesses cut no-shows by confirming bookings over WhatsApp
- **AI agent integration** — Wire WhatsApp into n8n, Typebot, or Dify without writing a Baileys integration
- **Multi-number agency operations** — Manage dozens of client WhatsApp numbers from one API

![Evolution API instance manager screenshot showing QR code connection](CLOUDINARY_URL "Evolution API WhatsApp instance connection")

## Dependencies for Evolution API Docker hosted on Railway

Evolution API ships as a single Node.js service that talks to WhatsApp via Baileys. You need PostgreSQL for persisting instances and messages, plus Redis for cache. A persistent volume keeps WhatsApp auth data alive across redeploys — without it, every restart forces a fresh QR scan.

### Deployment Dependencies for Managed Evolution API Service (OSS WhatsApp Automation)

This template provisions Railway-managed PostgreSQL and Redis alongside the Evolution API container. Postgres stores instance configuration and message history. Redis caches active connection state. All services communicate over Railway's private network.

### Implementation Details for Evolution API (Using Evolution API official docker image)

The template deploys `evoapicloud/evolution-api:v2.3.7` on port 8080 — a pinned release rather than `latest`, so upstream pushes can't silently change behavior. `SERVER_URL` is auto-set to your Railway domain so webhooks resolve correctly. `AUTHENTICATION_API_KEY` is auto-generated and required in the `apikey` header on every request.

## Environment Variables Reference for Evolution API on Railway

| Variable | Description | Value |
|----------|-------------|-------|
| `DATABASE_PROVIDER` | Tells Evolution API which database driver to use. | `postgresql` |
| `DATABASE_CONNECTION_URI` | Postgres connection string. Auto-set from the Postgres service. | `${{Postgres.DATABASE_URL}}` |
| `CACHE_REDIS_ENABLED` | Enables Redis caching for connection state. | `true` |
| `CACHE_REDIS_URI` | Redis connection string. Auto-set from the Redis service. | `${{Redis.REDIS_URL}}` |
| `SERVER_URL` | Public URL for webhook callbacks. Auto-set to your Railway domain. | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| `AUTHENTICATION_API_KEY` | Global API key required in the `apikey` header. Auto-generated. | `${{secret(64, "abcdef0123456789")}}` |

## How does Evolution API compare against other WhatsApp API platforms

### Evolution API vs Meta WhatsApp Cloud API (Meta Business API Alternative)
* **Approval process:** Evolution API connects instantly via QR code; Meta requires business verification and template review that can take weeks
* **Pricing model:** Evolution API costs only your hosting bill; Meta charges per-conversation fees that vary by country
* **Message flexibility:** Evolution API sends free-form text anytime; Meta restricts you to approved templates outside a 24-hour window

### Evolution API vs Twilio WhatsApp API (Twilio Alternative)
* **Cost structure:** Evolution API has no per-message fee once deployed; Twilio charges per message plus Meta's fees on top
* **Setup complexity:** Evolution API deploys in one click on Railway; Twilio requires Meta Business Manager plus Twilio account configuration
* **Data control:** Evolution API stores everything in your own Postgres instance; Twilio retains metadata on its own infrastructure

### Evolution API vs Wassenger (Wassenger Alternative)
* **Self-hosting option:** Evolution API runs entirely on your own Railway project; Wassenger is SaaS-only with tiered subscriptions
* **Open-source access:** Evolution API's full source is on GitHub; Wassenger's backend is closed
* **Multi-instance pricing:** Evolution API's cost stays flat regardless of instance count; Wassenger charges per connected number

## How to use Evolution API (the OSS WhatsApp REST API)?

Deploy the template, create a WhatsApp instance via the API with your auto-generated key, and scan the returned QR code from WhatsApp's Linked Devices menu.

## How to self host Evolution API on other VPS Services (Evolution API self hosting guide)

### Clone the Repository
Clone `https://github.com/EvolutionAPI/evolution-api` or pull the official image from Docker Hub.

### Install Dependencies
Ensure Docker and Docker Compose are installed, plus a reachable PostgreSQL and Redis instance.

### Configure Environment Variables
Copy `.env.example` to `.env` and set `DATABASE_CONNECTION_URI`, `CACHE_REDIS_URI`, `SERVER_URL`, `AUTHENTICATION_API_KEY`.

### Start the Evolution API Application
Run `docker compose up -d` to start the API alongside Postgres and Redis.

## Official Pricing of Evolution API (Evolution API pricing)

Evolution API is released under the Apache-2.0 license and is free to self-host indefinitely, with no per-message or per-instance fees from the project. Your only cost is the infrastructure it runs on — there's no official managed cloud version.

## Evolution API cloud vs self hosted comparison (Pricing, features, costs, and more)

Since there's no official hosted version, every deployment is self-hosted by definition. The comparison that matters is against Meta's Cloud API: you trade built-in compliance guarantees for zero per-message fees and full data control.

### Monthly cost of self hosting Evolution API on Railway

A typical deployment on Railway costs $10-20/month, covering the API container plus Postgres and Redis. Cost scales mildly with message volume, but there's no per-conversation fee like Meta's.

### System Requirements for Hosting Evolution API on a VPS

Minimum: 1 vCPU, 1 GB RAM, 10 GB storage for a single instance. Each added WhatsApp instance adds memory overhead. Docker and Docker Compose are required. For 5+ instances, allocate 2 vCPU and 2 GB RAM.

## Frequently Asked Questions (FAQs)

### What is Evolution API self hosted?
The open-source WhatsApp REST API running on your own infrastructure. You control the database, session data, and API key.

### How much does Evolution API self hosting cost on Railway?
Expect $10-20/month with Postgres and Redis included. Railway bills by usage, not per message or connected number, so cost stays predictable.

### Is Evolution API free to use?
Yes. It's Apache-2.0 licensed and free to self-host with no usage caps. You only pay for the Railway infrastructure it consumes.

### What messaging features does Evolution API support?
Text, media, location, contacts, buttons, lists, group management, and webhook events. Built-in integrations for Chatwoot, Typebot, n8n, and OpenAI-based bots.

### Where can I download Evolution API?
Source is on GitHub at `github.com/EvolutionAPI/evolution-api`. The official Docker image is `evoapicloud/evolution-api` on Docker Hub.

### What are some alternatives to Evolution API?
Meta's official WhatsApp Cloud API, Twilio's WhatsApp API, Wassenger, 360dialog, and WAHA. Evolution API is the most flexible for developers who want self-hosted control without per-message fees.
