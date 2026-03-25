# Production readiness audit

## What was missing or weak (initial)

| Severity | Item |
|----------|------|
| Critical | Default `JWT_SECRET` allowed in production |
| Critical | `GET /deliveries/:id`, `calculateCost`, `PATCH` status — IDOR / driver impersonation |
| Critical | `DriversController` — `GET :id` shadowed `GET leaderboard` and weak access control on mutations |
| Critical | `POST /firebase/send-push` callable by any authenticated user |
| High | Socket.IO CORS `origin: '*'` |
| High | `POST /drivers` could target arbitrary `userId` |
| High | Orders/recommendations lacked explicit `@Roles` |
| High | `GET /documents/:id` leaked metadata across users |
| Medium | No `compression`; no production env template |
| Medium | FAQ required JWT unnecessarily |

## What was fixed (this delivery)

- Production bootstrap validation for `JWT_SECRET` and `MONGODB_URI`.
- Delivery visibility, pricing updates, status updates, cancel (incl. admin), list (admin sees all).
- Driver route ordering + self/admin access pattern; sensitive endpoints admin-only where appropriate.
- Orders customer-scoped; recommendations explicitly roled.
- Public FAQs via `@Public()`.
- Document fetch/delete authorization.
- Admin-only Firebase test push; module imports `AuthModule` for guards.
- WebSocket CORS allowlist in production.
- Response compression.
- `backend/.env.example`.
- Tests updated; `npm test` passes.

## What remains / needs verification

| Item | Notes |
|------|-------|
| ESLint **errors** in `firebase.service.ts` (`no-var-requires`) | Pre-existing; CI may fail `npm run lint` until refactored to `import` or eslint-disable with justification |
| WebSocket **room authorization** | Clients can still `subscribeToDelivery` without server-side proof of participation (*inferred* risk) |
| **`VerifiedDriverGuard`** | Still unused on HTTP routes |
| **Stitch/WebView** primary UI | Not a full native Flutter product shell; E2E/mobile QA still heavy |
| **MongoDB backups, secrets manager, K8s probes** | Operational; not codified in repo |
| **npm audit** | 40+ vulnerabilities reported locally — triage separately |
| **E2E API tests** | No supertest suite in repo yet |
| **Flutter ↔ API contract** | If clients called `send-push` as non-admin, they will now get **403** (expected) |

## Production-ready verdict

- **Backend core API**: **Closer to production-ready** for authz on touched domains; **not** “done” until lint debt, E2E tests, ops runbooks, and WebSocket subscribe hardening are addressed.
- **Frontend**: **Not** fully production-ready as a native app; Stitch-driven UX remains a gap for store release quality.

*Facts vs inference:* Items in tables are grounded in code review and edits except WebSocket subscribe and ops rows, marked *inferred*.
