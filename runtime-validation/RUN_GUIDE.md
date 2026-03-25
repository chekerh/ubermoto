# Run guide

## Prerequisites

- **Node.js** 18+ (CI uses 18 and 20).
- **MongoDB** reachable at a URI you control (local default: `mongodb://127.0.0.1:27017/...`).
- **Flutter SDK** (for mobile app): 3.x per `pubspec.yaml`.

## Backend (API)

```bash
cd backend
npm ci          # or npm install
cp .env.example .env.local   # then edit values
# Minimum in .env.local:
#   MONGODB_URI=mongodb://127.0.0.1:27017/nassib
#   JWT_SECRET=<long random string>
#   NODE_ENV=development
#   PORT=3001

rm -rf dist     # if nest build fails with ENOTEMPTY
npm run build
npm run test      # unit tests (Jest, src/**/*.spec.ts)
npm run test:e2e  # HTTP smoke: health, public /faqs, auth + /deliveries (MongoDB Memory Server; first run may download binary)
npm run start:prod
# or: npm run start:dev
```

**Default port:** `3001` if `PORT` unset (`main.ts`).

**If `EADDRINUSE` on 3001:** choose another `PORT` (e.g. `3010`) and set the Flutter `AppConfig.backendPort` to match (or use `--dart-define` when that is wired).

**Swagger UI:** `http://localhost:<PORT>/api`

## Demo catalog (optional)

From `backend/` (uses `MONGODB_URI` from env or `.env.local`):

```bash
npm run seed:catalog
```

Creates **Demo Merchant (QA)**, categories (`food`, `groceries`, `pharmacy`), and three products. Safe to re-run: skips if products already exist for that merchant.

## Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run        # device or simulator required
# or
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

### Web + Cursor Browser MCP (interactive QA)

```bash
cd frontend
flutter run -d web-server --web-port 8080
```

Then follow **`runtime-validation/BROWSER_MCP_QA_PLAYBOOK.md`** to drive the UI via MCP.

**API URL:** `frontend/lib/config/app_config.dart` — default **3001**, or override with `--dart-define=BACKEND_PORT=...` / `--dart-define=API_BASE_URL=...` so it matches the API `PORT`.

- Android emulator → `http://10.0.2.2:<PORT>`
- iOS simulator / desktop → `http://localhost:<PORT>`

## Environment variables (backend)

See `backend/.env.example`. Required at runtime:

| Variable | Required |
|----------|----------|
| `MONGODB_URI` | Yes (throws if missing) |
| `JWT_SECRET` | Yes; in **production** must not be missing or `default-secret` |

Optional: `FRONTEND_ORIGINS`, `WEBSOCKET_CORS_ORIGINS`, Firebase paths, Sentry, throttle tuning.

## Platform caveats

- **MongoDB must be running** before the API; `/health` reports Mongo status.
- **Port alignment:** Flutter and backend `PORT` must match for real-device testing.
- **Stitch UI:** Primary screens load bundled HTML in a WebView; full UX validation needs a device or desktop `flutter run`.
