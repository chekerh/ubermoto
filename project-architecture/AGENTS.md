# Agent guidance (AI / Cursor)

## Project context

- **Monorepo**: `backend/` = NestJS + MongoDB + Socket.IO; `frontend/` = Flutter + Riverpod.
- **Product names in code**: “Nassib” (API/UI), repo folder “ubermoto”, pubspec name `ubertaxi_frontend` — treat as **one product** with naming debt.
- **Current UI reality**: `frontend/lib/main.dart` uses **`StitchViewer`** (WebView + bundled HTML) for most screens after auth; Dart `features/` and `services/` exist for API integration but may not back every stitch route.

## Important folders

| Path | Use when |
|------|----------|
| `backend/src/auth/` | JWT, guards, registration |
| `backend/src/deliveries/`, `delivery-matching.service.ts` | Delivery lifecycle + realtime |
| `backend/src/websocket/delivery.gateway.ts` | Socket events |
| `frontend/lib/services/` | HTTP clients — match patterns here |
| `frontend/lib/features/*/providers/` | Riverpod state |
| `frontend/lib/config/app_config.dart` | API base URL / port |
| `project-architecture/` | Architecture + API map + test plan |

## Conventions inferred

- **Nest**: One module per folder; DTOs with `class-validator`; controllers thin, logic in services.
- **Guards**: `JwtAuthGuard` + `RolesGuard` + `@Roles()` — absence of `@Roles` means **any authenticated user**.
- **Flutter**: `ApiService.get/post` with `requiresAuth`; tokens in secure storage; exceptions via `AppException`.
- **Formatting**: ESLint + Prettier (backend), `flutter_lints` (frontend).

## Do

- Prefer **small, focused diffs** aligned with the user request.
- Add **tests** next to code you change (`*.spec.ts` or `flutter_test`).
- Update **`project-architecture/API_MAP.md`** when adding or renaming HTTP routes (if project policy is to keep it in sync).
- Use **environment variables** for secrets; never commit real credentials.
- Verify **role and ownership** rules when touching ID-based endpoints.

## Don’t

- Don’t assume Stitch HTML calls the API — **verify** wiring.
- Don’t add new “magic” default secrets or disable throttling globally.
- Don’t broaden WebSocket CORS without explicit user approval.
- Don’t rename the whole product across iOS/Android bundle IDs without a dedicated migration task.

## Safe modification workflow

1. Read adjacent service + schema + existing tests.
2. Implement change; keep DTOs and Swagger decorators in sync where used.
3. Backend: `npm run lint && npm run test`.
4. Frontend: `flutter analyze` and `flutter test`.
5. For realtime features: smoke-test with `scripts/test-realtime-features.sh` (*if applicable to change*).

## How to validate before finishing

- **API**: Hit Swagger `http://localhost:<PORT>/api` or Postman collection `backend/UberMoto_API.postman_collection.json`.
- **Auth**: Obtain JWT via `/auth/login`, reuse for protected routes.
- **Mobile**: Run on emulator; confirm `AppConfig.baseUrl` matches host port.
- **Security regression**: Re-read `AUTH_AND_SECURITY.md` checklist for routes you touched.

## Where documentation lives

- Primary technical docs: **`/project-architecture/`** (this folder).
- Security audit snapshot: **`SECURITY_AUDIT.md`** (repo root).
