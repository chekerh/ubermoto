## Implementation plan (phased)

### Phase 0 — Repo reality + stabilization (done / ongoing)
- QA remediation (health 503, docs upload wiring, admin catalog correctness)
- Clean dependency hygiene and `.gitignore`

### Phase 1 — Subscription + entitlements foundation (next)
- Add Stripe integration (server):
  - webhook endpoint + idempotent storage
  - merchant checkout + portal sessions
  - Subscription + Entitlement models
- Add `GET /me/entitlements`
- Add entitlement guards/helpers for merchant write endpoints

### Phase 2 — Admin dynamic content/settings
- Content keys (pricing table, announcements, FAQs, feature flags)
- Draft/publish flow + audit log
- Admin UI editors (Flutter) for content keys

### Phase 3 — Merchant dashboard “paid value”
- Merchant analytics pages (basic + advanced)
- Promo/campaign management gated by plan
- Operations settings (hours, regions)

### Phase 4 — Production hardening
- S3 storage adapter for documents
- Background jobs for webhook retries and rollups
- Observability: request IDs, structured logs, dashboards
- Security: admin MFA, audit export, pen-test checklist

### Phase 5 — Release readiness
- Expand e2e flows (orders/promos/drivers)
- Play Store / App Store operational checklists
- Incident runbook + rollback strategies

