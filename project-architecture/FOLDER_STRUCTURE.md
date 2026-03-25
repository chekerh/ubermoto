# Folder structure

## Repository root

| Path | Purpose | Assessment |
|------|---------|------------|
| `backend/` | NestJS API, Jest tests, Swagger, Postman collection | **Well organized** by domain module |
| `frontend/` | Flutter app (Dart), Stitch HTML, platform folders | **Mixed**: Dart architecture is reasonable; large `stitch/` tree is parallel to `lib/` |
| `.github/workflows/` | CI for backend and frontend | **Good** — path-filtered pipelines |
| `scripts/` | Helper scripts (e.g. realtime test shell) | **Useful**; keep documented when adding ops scripts |
| `project-architecture/` | This documentation workspace | **New** — anchor for future technical docs |
| `SECURITY_AUDIT.md` | Existing security notes | **Keep** as sibling; link from `AUTH_AND_SECURITY.md` |
| `package.json` (root) | Declares `firebase-admin` only | **Unclear** — minimal root package; backend has its own deps (*inferred*: optional shared tooling or incomplete root setup) |

## Backend (`backend/`)

| Path | Purpose |
|------|---------|
| `src/main.ts` | Bootstrap, Swagger, CORS, global pipes/filters |
| `src/app.module.ts` | Root module graph, throttling, monitoring middleware |
| `src/config/` | Database and other configuration services |
| `src/common/` | Shared filters, utilities |
| `src/auth/` | Auth controller/service, JWT strategy, guards, DTOs |
| `src/users/` | Users controller, addresses controller, schemas |
| `src/drivers/`, `src/deliveries/`, `src/orders/`, `src/motorcycles/` | Core operational domains |
| `src/catalog/`, `src/promo-codes/`, `src/recommendations/` | Commerce / growth |
| `src/documents/` | File upload + verification |
| `src/admin/` | Admin-only aggregated operations |
| `src/surge/` | Surge rules + pricing read |
| `src/notifications/` | Preferences + inbox |
| `src/support/` | Tickets, FAQ, feedback |
| `src/firebase/` | FCM integration |
| `src/websocket/` | Socket.IO gateway |
| `src/health/` | Health checks |
| `src/core/` | Cross-domain services (e.g. cost calculator) |
| `test/` | E2E config (`jest-e2e.json`) — *verify* coverage |
| `uploads/` | Runtime document storage (*inferred* from controller paths) |

**Improvement ideas**

- Add a short `backend/README.md` with env vars and `PORT` behavior if not already present.
- Consider `libs/` only if true shared packages emerge; current flat `src/` is fine for this size.

## Frontend (`frontend/`)

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Firebase/monitoring init, routes |
| `lib/config/app_config.dart` | Base URL and port constants |
| `lib/core/` | Theme, errors, map controller, utilities |
| `lib/services/` | HTTP clients (auth, orders, catalog, websocket, etc.) |
| `lib/features/` | Riverpod feature modules |
| `lib/models/` | Data classes |
| `lib/widgets/` | Reusable UI (maps, sheets, components) |
| `lib/stitch/` | `StitchViewer` and related glue |
| `stitch/` | Static HTML/CSS/JS prototypes |
| `android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/` | Platform embedding |

**Improvement ideas**

- Reduce reliance on `stitch/` for primary flows over time, or generate Flutter from design tokens explicitly.
- Align `pubspec.yaml` `name:` / description with product naming (`Nassib` vs `ubertaxi_frontend`).
- Ensure every stitch route used in `main.dart` is listed under `flutter: assets:` (several folders are; *verify* `driver_earnings` and others if adding).

## What is well organized

- **Backend** domain boundaries map cleanly to routes and schemas.
- **Frontend** separation of `services` vs `features` vs `core`.
- **CI** split by path.

## What should improve

- **Single source of truth for product name** across repo, Swagger, and stores.
- **Documentation** was sparse at repo root before `project-architecture/`; consider linking from root `README` (*optional user follow-up*).
