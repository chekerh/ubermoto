# Agent guidance (post-delivery)

## Before editing

1. Read `delivery-workspace/PRODUCTION_READINESS_AUDIT.md` and `SECURITY_REVIEW.md`.
2. For API work, check `deliveries.service.ts`, `drivers.service.ts`, and `auth/guards/*` — authorization changed recently.
3. Run `cd backend && npm test` after backend changes.

## Conventions

- **Guards**: `JwtAuthGuard` + `RolesGuard`; use `@Public()` for unauthenticated reads; use `@Roles()` when restricting by role.
- **Driver routes**: Register **static paths** (`leaderboard`, `user/:userId`) **before** `GET :id`.
- **Deliveries**: Prefer service methods that accept `requesterSub` + `role` instead of trusting IDs alone.

## Do not

- Reintroduce `origin: '*'` on Socket.IO for production.
- Add endpoints that send push notifications without admin/system guard.
- Bypass `validateProductionEnvironment` for production deploys.

## Validate

- `npm run build` + `npm test` (backend).
- `flutter analyze` (frontend).
- Manual role checks from `delivery-workspace/TEST_PLAN.md` when touching authz.

## Documentation

- Log substantive changes in `delivery-workspace/ACTIONS_LOG.md`.
- Update `project-architecture/API_MAP.md` if you maintain it alongside code changes.
