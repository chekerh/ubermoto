# Authentication and security

## Auth mechanism

- **HTTP API**: **JWT** (HS256 via `@nestjs/jwt`), Bearer token in `Authorization` header.
- **Issuance**: `AuthService.generateToken` signs payload `{ sub, email, role }` (`backend/src/auth/auth.service.ts`).
- **Validation**: `JwtStrategy` loads user from DB on each request via `AuthService.validateUser` and attaches enriched object (`sub`, `email`, `role`, `isVerified`, etc.) to `request.user`.

## Session / token handling

- **No refresh token** flow observed in reviewed code — single `access_token` with expiry from `JWT_EXPIRES_IN` (default `1h` in `auth.module.ts`).
- **Storage (Flutter)**: `StorageService.saveToken` / `getToken` using `flutter_secure_storage` (`frontend/lib/core/utils/storage_service.dart`).

## Roles and permissions

- **Enum**: `CUSTOMER`, `DRIVER`, `ADMIN` (`backend/src/users/schemas/user.schema.ts`).
- **Enforcement**: `RolesGuard` + `@Roles(...)` on handlers; if `@Roles` omitted, **any authenticated user passes** `RolesGuard` (`roles.guard.ts` returns `true` when no metadata).
- **VerifiedDriverGuard** (`backend/src/auth/guards/verified-driver.guard.ts`): requires `role === DRIVER` and `isVerified === true`. **Not applied** on any controller in the grep sweep — *gap*: unverified drivers may use many driver-ish endpoints if IDs are guessable.

## Sensitive flows

| Flow | Protection | Gap |
|------|------------|-----|
| Password change | `PATCH /users/me/password` + JWT | OK if bcrypt compare enforced in service (*verify* `users.service.ts`) |
| Account delete | `DELETE /users/me` | Irreversible — ensure client confirmation |
| Document upload | DRIVER role for `POST /documents/upload` | Other document routes less restricted |
| Admin actions | `@Roles(ADMIN)` on `admin.controller`, surge, parts of catalog | — |
| Push test | `POST /firebase/send-push` | **JWT only** — any logged-in user may send arbitrary pushes to a token they supply |

## Validation / sanitization

- Global `ValidationPipe`: `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true` (`main.ts`).
- File upload: size cap 5MB, mime allowlist in `documents.controller.ts`.

## Rate limiting / middleware / protections

- **Throttling**: `ThrottlerModule` global guard; `GET /health` uses `@SkipThrottle()`.
- **Helmet**: enabled in `main.ts` with `crossOriginResourcePolicy: false`.
- **CORS**: Dynamic origin callback; production allows only `FRONTEND_ORIGINS` entries; non-browser clients often send no `Origin` and are allowed.
- **Sentry**: Error monitoring backend.

## WebSocket security

- Connection requires verifiable JWT (`jwtService.verify` in `handleConnection`).
- **CORS `origin: '*'`** on gateway — permissive; tighten for production.
- **Room subscription**: `subscribeToDelivery` does not appear to verify the user is party to that delivery (*inferred* information disclosure risk).

## Vulnerabilities or weak spots (factual from code review)

1. **Default JWT secret** if `JWT_SECRET` unset (`'default-secret'`).
2. **Authorization holes** on routes with `JwtAuthGuard` + `RolesGuard` but **no `@Roles`** — notably:
   - `GET /deliveries/:id`, `POST /deliveries/:id/cancel`, `POST /deliveries/:id/calculate-cost`
   - Many `drivers` mutating routes without role checks
   - `GET /documents/:id`
3. **Orders controller**: no `@Roles` on customer endpoints — *inferred*: customers could theoretically hit others’ IDs if services do not scope by `req.user.sub` (*verify* each service method).
4. **FCM send endpoint** open to any authenticated principal.
5. **Stitch / WebView** UI may execute remote or bundled HTML — treat as **high trust** content only.

## Recommendations

| Priority | Action |
|----------|--------|
| High | Remove default JWT secret; fail boot if missing in production |
| High | Add `@Roles` + **resource-level checks** (user owns delivery/order/document) on all ID-based routes |
| High | Restrict `POST /firebase/send-push` to **ADMIN** or dev-only flag |
| Medium | Apply `VerifiedDriverGuard` to driver operational routes (accept/start/complete delivery, location updates) |
| Medium | Lock down Socket.IO CORS and validate delivery room membership |
| Medium | Add refresh tokens or shorter access + silent renew strategy for mobile |
| Low | Document required env vars in `backend/README.md` |

Also see root **`SECURITY_AUDIT.md`** for any historical findings not duplicated here.
