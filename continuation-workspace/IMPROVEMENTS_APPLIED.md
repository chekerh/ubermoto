# Improvements applied (this session)

| Change | Why | Impact |
|--------|-----|--------|
| `delivery.gateway.spec.ts` | WebSocket authz was security-critical; lacked automated regression tests | Safer refactors; documents expected behavior for customer / driver / admin |
| `AppConfig` `BACKEND_PORT` / `API_BASE_URL` | Docs and runtime validation called out port mismatch (`EADDRINUSE` → alternate `PORT`) | Devs can `flutter run --dart-define=BACKEND_PORT=3010` or set full base URL without editing source |
| `continuation-workspace/*` | User-requested continuation artifact | Single place for state, QA, and next actions for future sessions |
| E2E suite + ESLint tsconfig | Supertest smoke without external Mongo; lint included `test/` | `npm run test:e2e` for CI/local regression; no parsing error on `test/*.ts` |
