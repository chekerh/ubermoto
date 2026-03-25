## Next steps (living list)

### Done in codebase (see `ACTIONS_LOG.md`)

- Billing module: Stripe webhooks, plans, subscriptions, entitlements, merchant checkout/portal.
- Server-side feature guard for merchant catalog writes; product limits; admin bypass for `FeatureGuard`.
- Dynamic content module + seeds (pricing table, announcements, feature flags).
- Flutter: entitlements, merchant billing, merchant registration (Stitch), merchant home + inventory, logout state reset, catalog write UX gating.

### Near-term engineering

1. **E2E**: Extend `test/app.e2e-spec.ts` (or split files) for merchant register → entitlements → product CRUD with seeded plans (Stripe mocked or skipped).
2. **Stripe production**: Deep links / universal links for checkout return; document env vars in `backend/.env.example`.
3. **Customer/driver**: Replace or bridge critical Stitch flows with tested Flutter navigation where product requires it.

### Product / ops (larger)

- Merchant acquisition funnel, analytics, loyalty (see original product spec).
- Document storage (e.g. S3 + signed URLs) if uploads leave local `uploads/`.
- Admin MFA, broader audit, Sentry/dashboards in prod.

### Quality bar (before “launch complete”)

Run and record: `npm test`, `npm run test:e2e`, `npm run build`, `flutter test`, plus a **manual** smoke on staging (register, pay, catalog, order if applicable).

Refer to **`PRODUCTION_READINESS.md`** for the explicit “not done until…” list.
