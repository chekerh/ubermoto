## Deployment plan

### Environments
- **dev**: local Mongo + local backend + flutter run
- **staging**: hosted API + managed Mongo; Stripe test mode
- **prod**: hosted API + managed Mongo; Stripe live mode

### Config / env vars (backend)
Required:
- `MONGODB_URI`
- `JWT_SECRET`
- `NODE_ENV`
- `FRONTEND_ORIGINS`

Billing (new):
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PORTAL_RETURN_URL`

Storage (future):
- `S3_BUCKET`, `AWS_REGION`, credentials

### Health checks
- `GET /health` for DB readiness
- `GET /system/version` for build verification

### Observability
- Sentry DSN per environment
- Structured logs, request IDs, dashboards

### Rollback
- Blue/green or quick revert to previous image
- Webhook processing must be backward compatible (store raw events)

