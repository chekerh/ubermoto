# Next steps

> **Continuation track:** see `/continuation-workspace/` for live state, QA log, and prioritized next actions.

## Immediate

1. ~~Fix **ESLint errors** in `firebase.service.ts`~~ — addressed (imports); many **warnings** remain repo-wide.
2. **Supertest E2E** — baseline in `backend/test/app.e2e-spec.ts` (health, `/faqs`, deliveries 401, register + JWT). Extend for delivery visibility / driver flows.
3. ~~**WebSocket delivery room** authorization~~ — implemented in `delivery.gateway.ts`; **unit tests** in `delivery.gateway.spec.ts`.
4. Run **`npm audit fix`** in a controlled branch; retest.

## Short term

- Flutter: environment-specific **base URL** via flavors or `--dart-define`.
- Apply **`VerifiedDriverGuard`** to driver operational routes after product sign-off.
- Expand **monitoring**: structured logs, request IDs, uptime checks on `/health`.

## Long term

- Migrate primary UX from **Stitch** HTML to native Flutter screens for accessibility and testability.
- Object storage for **document uploads** (S3-compatible).
- Redis adapter for **Socket.IO** if running multiple API instances.

## Working in Cursor / agents

See `AGENTS.md` in this folder and `project-architecture/` for broader context.
