# Evolution API on Railway

Evolution API — open-source WhatsApp REST API built on Baileys. Connect a personal WhatsApp number over HTTP with no Meta Business API approval and no per-message fees. Deploy on Railway with one click.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new/template/EVOLUTION_API_TEMPLATE_CODE)

## Features

- **No Meta approval needed** — connects to a real WhatsApp account via QR code, not the official Business API.
- **REST + webhooks** — send messages, manage groups, receive events over plain HTTP.
- **Multi-instance** — run many WhatsApp numbers from one deployment, useful for agencies.
- **Integrations** — built-in support for n8n, Typebot, Chatwoot, and OpenAI/Dify for bot workflows.
- **Persistent sessions** — WhatsApp auth state survives redeploys via a Railway Volume.
- **Pinned, stable image** — runs `evoapicloud/evolution-api:v2.3.7`, not a floating `latest` tag, so behavior doesn't change under you between deploys.
- **Built-in web manager** — a browser UI ships inside the same image at `/manager`, so you can create instances and scan QR codes without calling the API by hand.

## How to use

1. Click the **Deploy on Railway** button above.
2. Wait for the API, Postgres, and Redis services to come online (healthcheck passes automatically).
3. Open your Railway domain — you should see a JSON welcome response confirming the API is live.
4. Open `<your-domain>/manager` in a browser, create a WhatsApp instance, and scan the QR code from WhatsApp's Linked Devices menu. (Or do this over the API directly: `POST /instance/create` with your `AUTHENTICATION_API_KEY` in the `apikey` header.)
5. Send your first message via `POST /message/sendText/{instance}`. Full endpoint reference is in the [Evolution API docs](https://doc.evolution-api.com/).

## Environment Variables

| Variable | Description |
|----------|-------------|
| `DATABASE_PROVIDER` | Set to `postgresql`. |
| `DATABASE_CONNECTION_URI` | Auto-set from the Postgres service. |
| `CACHE_REDIS_ENABLED` | Auto-set to `true`. |
| `CACHE_REDIS_URI` | Auto-set from the Redis service. |
| `SERVER_URL` | Auto-set to your Railway public domain. |
| `AUTHENTICATION_API_KEY` | Auto-generated. Required in the `apikey` header on every API request. |

## Notes

- This template uses the official `evoapicloud/evolution-api:v2.3.7` Docker image (pinned — many competing templates track `:latest`, which can change behavior without warning).
- Persistent WhatsApp session/auth data lives on a Railway Volume mounted at `/evolution/instances`. Losing this volume means re-scanning the QR code for every instance.
- Postgres stores instances, messages, contacts, and chats. Redis handles caching and session state.
- WhatsApp Web can log you out of a linked device if it goes unused for too long — reconnect by fetching a fresh QR code for the instance.
- This connects a real personal WhatsApp number through an unofficial protocol (Baileys). It is not the official WhatsApp Business API — read Evolution API's docs on ban risk before using it for high-volume or spammy sending.
