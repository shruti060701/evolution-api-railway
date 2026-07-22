# Deploy and Host Evolution API-self-hosted on Railway

Evolution API is an open-source WhatsApp REST API built on the Baileys library. It connects a real WhatsApp number over HTTP — no Meta Business API approval, no per-conversation fees, no waitlist. This template deploys the API with Postgres, Redis, and persistent session storage pre-wired, so you're sending your first message in minutes.

## About Hosting Evolution API-self-hosted

Meta's official WhatsApp Business API requires business verification, a message template review process, and per-conversation pricing that adds up fast once you're past a few hundred chats a month. Evolution API skips all of that: it connects like a regular WhatsApp Web session, authenticated by scanning a QR code, then exposes that connection as a normal REST API. You get `POST /message/sendText`, webhook events for incoming messages, group management endpoints, and multi-instance support for running several numbers from one server. This template runs it self-hosted on Railway, so your message history, contacts, and API keys never touch a third party's infrastructure. Postgres persists everything; Redis handles caching and session state; a Railway Volume keeps your WhatsApp auth data alive across redeploys.

## Common Use Cases

- Customer support bots that reply to WhatsApp messages automatically
- Order and shipping notifications for e-commerce stores
- Appointment reminders for clinics, salons, and service businesses
- Lead qualification flows chained with n8n or Typebot
- Broadcast alerts for internal teams or on-call rotations

## Dependencies for Evolution API-self-hosted Hosting

- PostgreSQL, for instances, messages, contacts, and chat history
- Redis, for cache and session management
- A persistent volume, for WhatsApp authentication state

### Deployment Dependencies

- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Evolution API GitHub Repository](https://github.com/EvolutionAPI/evolution-api)
- [Evolution API Docker Hub Image](https://hub.docker.com/r/evoapicloud/evolution-api)

### Implementation Details

This template runs the official `evoapicloud/evolution-api:v2.3.7` image — pinned to a specific release rather than `latest`, so a Docker Hub push upstream can't change your running instance's behavior mid-deploy. Postgres and Redis connect through Railway's template variable references (`${{Postgres.DATABASE_URL}}`, `${{Redis.REDIS_URL}}`), and `SERVER_URL` is auto-set to your Railway domain so webhooks resolve correctly out of the box.

## Why Deploy Evolution API-self-hosted on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Evolution API-self-hosted on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
