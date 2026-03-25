# Current state (continuation)

**Product:** Monorepo “ubermoto” / branded **Nassib** — NestJS + MongoDB + Socket.IO backend; Flutter + Riverpod frontend. Most post-auth UX is **Stitch** HTML in a WebView (`StitchViewer`); Dart `features/` and `services/` integrate APIs where wired.

## What exists and is working (verified in repo / prior runs)

| Area | Status |
|------|--------|
| Auth (JWT), roles, throttling, helmet, compression | Implemented |
| Deliveries / orders / drivers / documents / catalog / support / surge / promo / notifications modules | Present in codebase |
| Authorization hardening on many ID-based routes (deliveries, drivers, orders, documents, Firebase push admin-only) | Documented in `delivery-workspace/` |
| Production bootstrap check for `JWT_SECRET` | `config/bootstrap-validation.ts` |
| WebSocket `/delivery` namespace: subscribe + location updates gated by ownership / assigned driver / admin | `delivery.gateway.ts` |
| Dev catalog seed | `npm run seed:catalog`, `scripts/seed-dev-catalog.ts` |
| Runtime validation notes | `runtime-validation/` (smoke tests, playbook for Browser MCP) |
| Architecture / API map / test plans | `project-architecture/` |

## Incomplete or partially implemented

- **Stitch ↔ API:** Not every HTML screen is guaranteed to call backend; needs per-route verification.
- **Document provider (Flutter):** TODOs for stats API and upload wiring (`document_provider.dart`).
- **Admin provider:** Hardcoded merchant id / empty category mapping TODOs.
- **Delivery matching:** Scoring TODOs (GPS, time, motorcycle type).
- **E2E:** `backend/test/app.e2e-spec.ts` — health, public `/faqs`, deliveries 401, customer register + authenticated list (`mongodb-memory-server`).
- **Native vs web QA:** Device WebView and maps not fully automated; MCP playbook targets Flutter web.

## Inferred (not re-proven this session)

- Prior session reported backend **93 tests** + build green; Flutter **24 tests** green.
- Port **3001** vs occupied host port remains an environment concern.

## Needs verification

- Run full `npm test` / `flutter test` after each substantive change.
- Optional: Browser MCP pass per `runtime-validation/BROWSER_MCP_QA_PLAYBOOK.md`.
- `npm audit` / dependency upgrades (called out in older next-steps docs).
