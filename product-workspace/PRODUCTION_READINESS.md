# Production readiness (honest status)

**This document is not a marketing claim.** It records what is implemented, what was validated in-repo, and what still blocks treating UberMoto/Nassib as “fully production-launched.”

## Validated in repository (2026-03-25)

| Check | Result |
|--------|--------|
| Backend unit tests (`backend/`: `npm test`) | 116 passed |
| Backend build (`npm run build`) | Pass |
| Backend e2e (`npm run test:e2e`, needs Mongo) | 5 passed (health, auth, deliveries smoke) |
| Flutter tests (`flutter test`) | All passed |
| `dart analyze` | 0 errors; remaining findings are **info** (style) across legacy Stitch/widgets |
| `.env` / `node_modules` / `dist` tracked in git | Not found (`.gitignore` covers `.env`, `node_modules`, build dirs) |
| Stripe test secret in source | Only test placeholder / spec values (e.g. `whsec_test` in Jest) |

## Implemented product slices (high level)

- Billing: Stripe webhook idempotency, plans, subscriptions, entitlements, merchant checkout/portal (API + Flutter), merchant usage endpoint.
- Merchants: registration, native merchant home, product inventory screen, entitlement-gated catalog writes (server + UI).
- Auth: JWT with email on user payload; merchant billing + global entitlements scoped to selected store; logout clears billing/entitlement state.
- Dynamic content and admin content APIs (per `ACTIONS_LOG.md`).

## Not production-complete — typical remaining work

These are **normal** for a marketplace going live; several are large or environment-specific:

1. **Stripe live**: Tunisia/business constraints, live keys, production webhook endpoint, return URLs / deep links, reconciliation and monitoring.
2. **Hosting & data**: Managed Mongo (Atlas or equivalent), backups, secrets management, CI/CD, staging vs prod config.
3. **Security depth**: Rate limits review, admin MFA, audit log completeness, penetration test, dependency/CVE process.
4. **App surface**: Much of customer/driver UX is still Stitch/HTML; parity with native flows, accessibility, and store policies.
5. **E2E coverage**: Paid flows (checkout webhook → entitlement → catalog) not covered end-to-end in automated tests.
6. **Operations**: Runbooks, on-call, legal (terms/privacy), support tooling, fraud/abuse playbooks.

## When to call the app “done”

Use a **defined launch checklist** (deploy, Stripe live, legal, monitoring, smoke tests on prod) and sign-off from stakeholders—not only green unit tests.

See also: `NEXT_STEPS.md`, `ACTIONS_LOG.md`, `AGENTS.md`.
