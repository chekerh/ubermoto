# Deployment checklist

## Prerequisites

- **MongoDB** reachable from API (Atlas or self-hosted).
- **Node 18+** (CI uses 18 and 20).
- **Secrets** stored in platform secret manager (not in git).

## Environment variables

Copy `backend/.env.example` → `.env` or `.env.local` (both loaded by `ConfigModule`).

| Variable | Required | Notes |
|----------|----------|--------|
| `MONGODB_URI` | Yes | Throws at runtime if missing (`DatabaseConfigService`) |
| `JWT_SECRET` | Yes; stricter in prod | Non-empty; **not** `default-secret` when `NODE_ENV=production` |
| `JWT_EXPIRES_IN` | No | Default `1h` |
| `PORT` | No | Default `3001` in `main.ts` if unset |
| `NODE_ENV` | Recommended | Set `production` in prod |
| `FRONTEND_ORIGINS` | Prod (browser) | Comma-separated allowed CORS origins |
| `WEBSOCKET_CORS_ORIGINS` | Prod (Socket.IO web) | Optional; falls back to `FRONTEND_ORIGINS` |
| `THROTTLE_TTL_MS`, `THROTTLE_LIMIT` | No | Defaults in `app.module.ts` |
| `FIREBASE_SERVICE_ACCOUNT_PATH` or `GOOGLE_APPLICATION_CREDENTIALS` | If using FCM | See `firebase.service.ts` |
| `SENTRY_DSN` | Optional | `sentry.config.ts` |

## Build & run (API)

```bash
cd backend
npm ci
npm run build
NODE_ENV=production node dist/main.js
```

*Note:* If `nest build` fails with `ENOTEMPTY` on `dist/`, run `rm -rf dist` and rebuild.

## Health

- `GET /health` — Mongo ping (skips throttle).
- `GET /system/version` — version metadata.

## Flutter client

- Align `frontend/lib/config/app_config.dart` `backendPort` / `baseUrl` with deployed host.
- Android emulator → `10.0.2.2`; physical device → LAN IP or public URL.
- Release builds: use `--dart-define` or flavors (*not implemented in repo — future work*).

## Rollback

- Keep previous container image / deployment revision.
- Mongo schema is Mongoose-only — no migration runner in repo; rollback = redeploy prior API + compatible data.

## Monitoring

- Sentry (backend) if `SENTRY_DSN` set.
- Add APM/log aggregation in your platform (not in repo).

## Security reminders

- TLS termination at load balancer / reverse proxy.
- Never commit `.env` or service account JSON.
