# Technical debt and recommendations

Priorities use **impact** (user/security/ops) and **effort**. Items are grounded in the codebase as of documentation generation.

## High impact

| Issue | Evidence | Recommendation |
|-------|----------|------------------|
| Driver route shadowing | `drivers.controller.ts`: `Get(':id')` is registered **before** `Get('leaderboard')` | Move static routes (`leaderboard`, `user/:userId`) **above** `Get(':id')` so `/drivers/leaderboard` is not parsed as an id |
| Inconsistent authorization | `RolesGuard` passes when `@Roles` absent; deliveries/drivers/documents expose ID routes without role narrowing | Add explicit `@Roles` and **ownership checks** in services (compare `req.user.sub` to entity `userId` / `driverId`) |
| JWT secret default | `JWT_SECRET \|\| 'default-secret'` in `auth.module.ts`, `jwt.strategy.ts` | Require secret in production; use config validation (e.g. Joi or custom bootstrap guard) |
| WebSocket hardening | `origin: '*'` in `delivery.gateway.ts` | Environment-specific allowed origins; validate delivery subscription |
| Unused verified driver guard | `VerifiedDriverGuard` exported but not used on controllers | Wire into driver delivery + location flows or delete if redundant |
| Product/repo naming drift | `ubermoto` folder, `nassib` backend name, `ubertaxi_frontend` pubspec | Single branding + rename backlog (docs, CI, bundle IDs *needs verification*) |

## Medium impact

| Issue | Evidence | Recommendation |
|-------|----------|------------------|
| Duplicate order history route | `GET /orders` and `GET /orders/history` both call `findAllForUser` | Remove alias or differentiate |
| Orders access control | `OrdersController` has no `@Roles` on user routes | Ensure `findOneForUser` / `create` always scope by JWT sub; add tests |
| FAQ requires auth | `SupportController` class-level `JwtAuthGuard` | Decide public vs authenticated; use `@Public()` decorator if you add one, or split controller |
| File storage on local disk | `documents.controller.ts` writes under `process.cwd()` | Move to object storage for horizontal scaling |
| Frontend/backend port coupling | `AppConfig.backendPort = 3003` vs `main.ts` default | Document single source or use build flavors / `--dart-define` |
| Stitch-first UX | `main.dart` routes most flows to HTML | Plan migration to Flutter widgets for accessibility and testability |

## Low effort quick wins

| Issue | Evidence | Recommendation |
|-------|----------|------------------|
| Sparse backend tests outside a few services | Only handful of `*.spec.ts` under `backend/src` | Add controller e2e tests for auth + one happy path per domain |
| Flutter widget test default | `frontend/test/widget_test.dart` may still be template | Replace with smoke test for `_AuthGate` or core widget |
| Postman collection maintenance | `UberMoto_API.postman_collection.json` | Regenerate from Swagger periodically |
| `root package.json` only firebase-admin | Root `package.json` | Clarify purpose or remove to avoid confusion |

## Duplication

- Admin driver verification appears in both `admin.controller` and `drivers.controller` (`PATCH :id/verification`) — *inferred*: overlapping responsibilities; consolidate or document canonical path.

## Missing tests (observed)

Backend spec files found: `auth.service.spec.ts`, `admin.service.spec.ts`, `catalog.service.spec.ts`, `core/utils/cost-calculator.service.spec.ts`, `deliveries.service.spec.ts`, `health.controller.spec.ts`, `notification-inbox.service.spec.ts`, `support.service.spec.ts`.  
**Missing** (*high value*): guards, JWT strategy integration, `orders`, `users`, `firebase`, `websocket`, most controllers.

## Architectural risks

- **Monolithic Nest app** without queue — traffic spikes hit API + Mongo directly.
- **Socket.IO + stateless HTTP** — sticky sessions or adapter (Redis) *needed* if multiple API instances (*inferred* ops gap).

## Maintainability

- DTO proliferation is healthy; ensure Swagger tags cover newer modules uniformly.
- Keep `API_MAP.md` updated when adding routes, or generate from OpenAPI.
