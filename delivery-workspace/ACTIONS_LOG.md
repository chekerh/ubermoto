# Actions log (chronological)

## Discovery

- Reviewed monorepo: `backend/` (NestJS 10, MongoDB, Socket.IO), `frontend/` (Flutter + Riverpod + Stitch WebView).
- Inspected controllers, guards, `main.ts`, `websocket`, `firebase`, tests, CI workflows, existing `project-architecture/` docs.

## Implemented changes

| Area | Change | Rationale |
|------|--------|-----------|
| Bootstrap | `validateProductionEnvironment()` in `src/config/bootstrap-validation.ts`, called from `main.ts` | Fail fast when `NODE_ENV=production` and `JWT_SECRET` missing or `default-secret` |
| HTTP | `compression` middleware in `main.ts` | Reduce response sizes |
| WebSocket | `resolveSocketIoCorsOrigin()` in `src/websocket/socket-cors.util.ts`, used by `delivery.gateway.ts` | Remove `origin: '*'` in production; require allowlist |
| Public routes | `Public` decorator + `IS_PUBLIC_KEY`, extended `JwtAuthGuard` with `Reflector` | Allow unauthenticated FAQ reads |
| Auth module | Register/export `JwtAuthGuard` in `auth.module.ts` | DI for `Reflector` in guard |
| Deliveries | `findOneVisibleToRequester`, `updateStatus` assigned-driver check, `calculateCost` authorization, `cancelDelivery` admin path + role param, `findAll` admin sees all | Close IDOR / privilege escalation |
| Deliveries controller | `@Roles` on list/cancel/calculate-cost; pass user context into service | Align HTTP with authorization model |
| Drivers | Reordered routes (`leaderboard`, `user/:userId` before `:id`); `assertAdminOrSelfDriverRecord` / `assertAdminOrMatchingUser`; create profile self-service check; restrict rating/increment to admin; guard earnings/location/etc. | Fix route shadowing + horizontal privilege issues |
| Orders | `@Roles(CUSTOMER)` on customer order routes | Drivers/admins cannot hit customer order APIs |
| Recommendations | Class-level `@Roles(CUSTOMER, DRIVER, ADMIN)` | Remove anonymous-role access ambiguity |
| Support | `@Public()` on `GET /faqs` | FAQs readable without JWT |
| Documents | `findOneForRequester`; GET `:id` and DELETE use it | Document metadata not leaked cross-user |
| Firebase | `RolesGuard` on controller; `POST /firebase/send-push` **ADMIN** only; `FirebaseModule` imports `AuthModule` | Prevent push abuse |
| Tests | Updated `deliveries.service.spec.ts` for new signatures and driver assignment | Keep suite green |
| Tooling | `backend/.env.example`; devDependency `@types/compression` | Deployment clarity + TS build |

## Verification run

- `rm -rf dist && npm run build` — **pass** (clean `dist` avoids occasional `ENOTEMPTY` from nest-cli).
- `npm test` — **pass** (93 tests).
- `npm run lint` — **exits non-zero** due to **pre-existing** `@typescript-eslint/no-var-requires` errors in `firebase.service.ts` (not introduced in this pass).
- `flutter analyze --no-fatal-infos --no-fatal-warnings` — **exit 0** (infos only).

## Documentation

- Created `/delivery-workspace/*` per delivery brief (this log + audit, architecture, security, deployment, tests, debt, next steps, agents).

*Note:* `project-architecture/API_MAP.md` (if present) may be **stale** until manually refreshed for new `@Roles`, public FAQ, and Firebase admin-only push.
