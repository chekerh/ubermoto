# Test execution report

## Automated — backend

| Command | Result | Notes |
|---------|--------|--------|
| `npm test` | **PASS** | 8 suites, 93 tests |
| `npm run build` | **PASS** | After clean `dist/` |
| `npm run lint` | **PASS (0 errors)** | 373 warnings remain |

## Automated — frontend

| Command | Result | Notes |
|---------|--------|--------|
| `flutter test` | **PASS** | 24 tests (`widget_test.dart` + providers/models) |
| `flutter analyze --no-fatal-infos --no-fatal-warnings` | **PASS (exit 0)** | 50 **info**-level issues (e.g. trailing commas), no errors as warnings |

## Manual / HTTP (API on port **3010**)

| Step | Expected | Actual | Result |
|------|----------|--------|--------|
| `GET /health` | 200, Mongo up | `{"status":"ok","info":{"mongodb":{"status":"up"}}}` | **PASS** |
| `GET /faqs` (no auth) | 200 | `200`, body `[]` | **PASS** |
| `POST /auth/register/customer` | 201 + `access_token` | JWT returned | **PASS** |
| `GET /users/me` + Bearer | 200, profile | User JSON, no password | **PASS** |
| `GET /catalog/categories` | 200 | `[]` (empty DB) | **PASS** |
| `POST /deliveries` + customer JWT | Create delivery | `status: pending`, ids set | **PASS** |

## Not executed (environment limits)

| Area | Reason |
|------|--------|
| `flutter run` + navigation | No simulator/device session in this run |
| Stitch WebView flows | Requires interactive app shell |
| Driver/admin multi-role UI | Same |
| Load / soak / k6 | Out of scope |
| E2E (Detox/Patrol/Maestro) | Not configured in repo |

## Blockers encountered

- **Port 3001 in use** — First bootstrap failed with `EADDRINUSE`; validation used **3010** for live HTTP tests. Default documented port remains **3001**; free the port or override `PORT` + Flutter config.
