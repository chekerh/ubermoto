# Security review

## Authentication

- **JWT** in `Authorization: Bearer`; validated by Passport JWT strategy; payload includes `sub`, `email`, `role`; full user loaded in `AuthService.validateUser`.
- **Production**: `validateProductionEnvironment()` rejects missing/weak `JWT_SECRET`.

## Authorization (fixes applied)

| Area | Control |
|------|---------|
| Deliveries | Viewer = customer owner OR assigned driver OR admin; status = assigned driver only; cost update = owner OR assigned driver OR admin; cancel includes admin path |
| Drivers | Admin or **own** driver record for sensitive operations; create profile ties `userId` to JWT except admin |
| Orders | Customer role for user order APIs |
| Recommendations | Explicit multi-role allow list |
| Documents | Owner or admin for read/delete |
| Firebase push test | **Admin only** |
| FAQs | **Public** (`@Public()` + extended `JwtAuthGuard`) |

## Validation & sanitization

- Global `ValidationPipe`: whitelist + forbid unknown properties.
- Document uploads: size/type checks in `documents.controller.ts`.

## Headers & transport

- **Helmet** enabled (`main.ts`).
- **CORS** allowlist in production (plus dev defaults).
- **Compression** enabled.

## Rate limiting

- Global `ThrottlerGuard`; health check uses `@SkipThrottle()`.

## Remaining risks

| Risk | Severity | Notes |
|------|----------|-------|
| WebSocket `subscribeToDelivery` / `updateLocation` without membership check | ~~High~~ **Mitigated** | `DeliveryGateway` now checks delivery owner, assigned driver (via Driver doc + JWT `sub`), or `ADMIN`; `updateLocation` requires assigned driver |
| JWT no refresh token | Medium | Short-lived access tokens only |
| `RolesGuard` without `@Roles` still allows any authenticated user on that handler | Medium | Audit remaining routes periodically |
| `firebase.service.ts` dynamic require | ~~Low~~ **Addressed** | ESM imports; lint errors cleared for that file |
| Default JWT in **development** still possible | Low | Acceptable for local dev only |

## Recommendations

1. Add integration tests for the role matrix above.
2. ~~Harden Socket.IO subscription~~ — implemented; add automated tests for subscribe/location edge cases.
3. Consider `@nestjs/config` schema validation (Joi/Zod) for all env vars at boot.
