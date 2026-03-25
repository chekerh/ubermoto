# Test plan

## Automated (current)

| Command | Scope |
|---------|--------|
| `cd backend && npm test` | Jest unit tests (`*.spec.ts` under `src/`) |
| `cd backend && npm run build` | TypeScript compile |
| `cd backend && npm run lint` | ESLint (may fail on `firebase.service.ts` require) |
| `cd frontend && flutter test` | Widget/unit tests |
| `cd frontend && flutter analyze --no-fatal-infos --no-fatal-warnings` | Static analysis |

## High-priority manual / future E2E

### Auth & roles

- Login customer / driver / admin; call wrong-role endpoint → **403**.
- `GET /faqs` **without** token → **200**.
- `POST /firebase/send-push` as customer → **403**; as admin → **200** (with valid Firebase config).

### Deliveries

- Customer creates delivery; **another** customer `GET /deliveries/:id` → **403**.
- Driver A assigned; Driver B `PATCH /deliveries/:id/status` → **403**.
- Driver **not** assigned `PATCH .../status` → **403**.
- `POST .../calculate-cost` as unrelated user → **403**.
- Admin `GET /deliveries` returns **all**; customer only own.
- Admin `POST .../cancel` cancels without being owner (*verify* business rules).

### Drivers

- `GET /drivers/leaderboard` returns leaderboard JSON (not treated as `:id`).
- Driver B calls `PATCH /drivers/:id/availability` for driver A’s id → **403**.
- `POST /drivers` with `userId` ≠ JWT sub as non-admin → **403**.

### Orders

- Driver token `POST /orders` → **403**.

### Documents

- User A `GET /documents/:id` for user B’s document → **403**.

### WebSocket

- Production: connection from disallowed origin fails when `WEBSOCKET_CORS_ORIGINS` / `FRONTEND_ORIGINS` omit it.
- Subscribe to arbitrary `deliveryId` still succeeds today — **document as known gap**.

## Edge & failure cases

- Expired JWT → **401**.
- Invalid Mongo id format → **400** or **500** depending on global filter (*verify*).
- Throttle burst → **429** (`ThrottlerGuard`).

## Suggested next automation

- Supertest: auth matrix + delivery visibility + driver self-access.
- Contract tests for OpenAPI (`/api` Swagger) vs responses.
