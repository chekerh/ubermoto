# Run guide — full stack (Nassib / Ubermoto)

## Tech stack

| Layer | Technology |
|-------|------------|
| API | NestJS 10, MongoDB (Mongoose), Socket.IO (`/delivery`), JWT, Throttler, Swagger `/api` |
| Client | Flutter 3.x, Riverpod, EasyLocalization, Stitch HTML in WebView (mobile) / iframe (web) |
| Realtime | `DeliveryGateway` (subscribe/location rules documented in `delivery-workspace/`) |

## Prerequisites

- **Node.js** 18+
- **Flutter** / Dart (see `frontend/pubspec.yaml` SDK constraint)
- **MongoDB** for a running API (local URI or Atlas)
- Optional: **Firebase** config for push/analytics (app continues if init fails)

## Backend

```bash
cd backend
npm ci   # or npm install
cp .env.example .env.local
# Edit .env.local — minimum:
#   MONGODB_URI=mongodb://127.0.0.1:27017/nassib
#   JWT_SECRET=<long random>
#   NODE_ENV=development
#   PORT=3001
#   FRONTEND_ORIGINS=http://localhost:8080

rm -rf dist   # if nest build ENOTEMPTY
npm run build
npm run start:dev
# or: npm run start:prod
```

**Automated checks (no external Mongo for e2e):**

```bash
npm test          # unit
npm run test:e2e  # Supertest + MongoDB Memory Server
npm run lint
npm run build
```

**Optional demo data:**

```bash
npm run seed:catalog   # requires MONGODB_URI
```

## Frontend

```bash
cd frontend
flutter pub get
# API port must match backend (default 3001):
flutter run -d web-server --web-port 8080 --web-hostname localhost \
  --dart-define=BACKEND_PORT=3001
# or device: flutter run
```

```bash
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings lib
```

### Web vs mobile Stitch

- **Mobile:** `webview_flutter` + `StitchBridge` JS injection.
- **Web:** iframe embed (`stitch_embed_web.dart`); **no** full `StitchBridge` — see `runtime-validation/BROWSER_MCP_QA_PLAYBOOK.md`.

## Startup sequence (manual full stack)

1. Start **MongoDB**.
2. Start **backend** on chosen `PORT`.
3. (Optional) `npm run seed:catalog`.
4. Start **Flutter** with matching `BACKEND_PORT` / `API_BASE_URL` (`frontend/lib/config/app_config.dart` + `--dart-define`).

## Platform notes

- **Android emulator:** `http://10.0.2.2:<PORT>` (default in `AppConfig`).
- **CORS:** dev allowlist includes `http://localhost:8080`; production needs `FRONTEND_ORIGINS`.
- **Health:** `GET /health` includes Mongo ping — fails if DB down (observed **500** on a live port when DB unhealthy).
