# Next steps

## Immediate (this week)

1. **Fix authorization gaps** on `GET/PATCH` by-ID routes for deliveries, orders, documents, and drivers — add service-layer checks against `req.user.sub` and explicit `@Roles` where missing (*see `AUTH_AND_SECURITY.md`*).
2. **Eliminate default `JWT_SECRET`** in production builds; add startup validation.
3. **Lock down** `POST /firebase/send-push` (admin-only or dev flag).
4. **Run backend tests + lint** after changes: `cd backend && npm run test && npm run lint`.
5. **Align ports**: document that Flutter `AppConfig.backendPort` must match `PORT` env for backend.

## Short-term roadmap (2–6 weeks)

- Add **Nest e2e** tests for: auth, deliveries happy path, admin verify driver.
- Apply **`VerifiedDriverGuard`** to operational driver endpoints or document why not.
- **WebSocket**: restrict CORS + validate `subscribeToDelivery` membership.
- **Flutter**: replace highest-traffic Stitch screen with native implementation (e.g. login or catalog).
- **Object storage** spike for document uploads (S3/MinIO).

## Longer-term (6+ weeks)

- Horizontal scaling: **Redis adapter** for Socket.IO; session stickiness story.
- **Refresh tokens** or OAuth device flow for mobile.
- **Observability**: structured logging, trace IDs, metrics dashboard.
- **Product unification**: one app name, store listings, and API branding.

## Future Cursor / agent workflow

1. Read **`project-architecture/AGENTS.md`** and **`API_MAP.md`** before editing.
2. For API changes: update controller → service → schema → DTO → Swagger; mirror in `API_MAP.md` if maintaining manually.
3. For Flutter changes: check `AppConfig` and `ApiService` patterns; run `flutter analyze` and `flutter test`.
4. Always add or extend **tests** in the same PR as behavior changes.
5. After security-sensitive edits, re-run **role-based** manual checks from `TEST_PLAN.md` section R1–R5.
