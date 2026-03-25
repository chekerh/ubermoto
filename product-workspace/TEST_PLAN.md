## Test plan

### Unit tests (backend)
- Entitlement evaluation logic
- Webhook idempotency (same event twice)
- Guards for role + entitlements
- Content schema validation

### Integration tests (backend)
- Stripe webhook signature verification (test helper)
- Checkout session creation for merchants
- Content draft/publish with audit log

### E2E (backend Supertest)
Minimum flows:
- Register customer → browse catalog → create order/delivery
- Register driver → upload documents → admin approves
- Merchant: create subscription → verify gated endpoint allowed/denied

### Frontend tests
- Entitlements provider behavior (loading, caching, refresh)
- Paywall/upgrade prompt rendering by plan
- Admin editors basic validation (required fields)

### Manual QA (release checklist)
- Billing: trial, upgrade, downgrade, cancel, payment failure
- Admin: content publish and immediate client refresh
- Security: permissions checks on admin routes
- Performance: cold start, map rendering, upload latency

