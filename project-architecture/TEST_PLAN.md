# Test plan

## Stack-appropriate tooling (recommended)

| Layer | Backend | Frontend |
|-------|---------|----------|
| Unit / integration | **Jest** + `@nestjs/testing` (already in `backend/package.json`) | **flutter_test**, **mockito** or **mocktail** (*add if not present*) |
| API contract | **Supertest** via `test/jest-e2e.json` script | Dart integration tests hitting staging API |
| E2E mobile | — | **Patrol** or **Maestro** (*optional*; not in repo today) |
| Load | k6 or Artillery | — |
| Security | OWASP ZAP baseline, `npm audit` | MobSF for mobile *optional* |

---

## Global test themes

### Authentication & sessions

| ID | What to test | Scenario | Expected | Priority | Level | Automation |
|----|--------------|----------|----------|----------|-------|------------|
| A1 | Login | Valid email + password | 200 + `access_token` | P0 | Integration | High |
| A2 | Login | Wrong password | 401 | P0 | Integration | High |
| A3 | Login | Phone identifier without `@` | Uses `findByPhoneNumber` path | P1 | Integration | High |
| A4 | JWT | Expired token on protected route | 401 | P0 | Integration | Medium |
| A5 | JWT | Missing secret in prod | Process exit or fail-fast | P0 | Unit/config | High |
| A6 | Register | Duplicate email | 409 | P1 | Integration | High |

### Authorization / roles

| ID | What to test | Scenario | Expected | Priority | Level | Automation |
|----|--------------|----------|----------|----------|-------|------------|
| R1 | Admin routes | CUSTOMER token on `GET /admin/dashboard` | 403 | P0 | E2E | High |
| R2 | Catalog write | CUSTOMER `POST /catalog/products` | 403 | P0 | E2E | High |
| R3 | Delivery create | DRIVER token `POST /deliveries` | 403 (has `@Roles(CUSTOMER)`) | P0 | E2E | High |
| R4 | IDOR | CUSTOMER A token fetches `GET /deliveries/:id` for B’s delivery | 403/404 *desired* — **document current behavior after test** | P0 | Integration | High |
| R5 | Documents | Non-owner `GET /documents/:id` | Should fail — **verify actual** | P0 | Integration | High |

### Rate limiting & health

| ID | What to test | Scenario | Expected | Priority | Level | Automation |
|----|--------------|----------|----------|----------|-------|------------|
| T1 | Throttle | Burst > `THROTTLE_LIMIT` in window | 429 | P2 | Integration | Medium |
| T2 | Health | `GET /health` | 200 + mongo up | P1 | Smoke | High |

---

## Feature-by-feature matrix

### Auth (`/auth`)

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Customer register → token shape | 201, JWT decodes to CUSTOMER | P0 | API | High |
| Driver register → driver profile exists | Can fetch driver by user id | P0 | Integration | Medium |
| Deprecated `/auth/register` | Still creates customer | P2 | API | Low |

### Users & addresses

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| `GET /users/me` strips password | No `password` key | P0 | API | High |
| Change password wrong current | 401 per API doc | P0 | API | Medium |
| CRUD address + single default | Only one `isDefault` | P1 | Integration | Medium |
| Favorites add/remove idempotent | Consistent messages | P2 | API | Medium |

### Catalog (public reads)

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| List categories empty vs seeded | 200 array | P1 | API | High |
| Search no `q` | Defined behavior (all vs empty) | P2 | API | Medium |
| Admin create product validation | 400 on bad DTO | P1 | API | High |

### Orders

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Create order as customer | Persists with user scope | P0 | Integration | High |
| Reorder copies line items | Business rule in service | P1 | Unit | High |
| Admin patch status | Transitions valid | P1 | Integration | Medium |
| Cross-user `GET /orders/:id` | Forbidden if not owner | P0 | **Security** | High |

### Deliveries

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Customer creates delivery | Emits `new_delivery` to DRIVER room | P0 | Integration (mock gateway) | Medium |
| Driver accept → assigned | Single winner; others rejected | P0 | Unit + integration | High |
| Status transitions | Invalid transition rejected | P1 | Unit | High |
| Cancel | Customer vs driver rules | P1 | Unit | High |
| Tip / rate | Only customer, once | P1 | Integration | Medium |
| `calculate-cost` | Surge + distance inputs | P1 | Unit (cost calculator) | High |

### WebSocket `/delivery`

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Connect no token | Disconnect | P0 | Integration | Medium |
| Driver `updateLocation` | Non-driver gets error payload | P0 | Integration | Medium |
| Subscribe arbitrary delivery id | *Current*: success — **risk** | P1 | Manual + future fix | Low |

### Drivers & motorcycles

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Availability toggles gateway emit | `driver_status_update` to ADMIN | P2 | Integration | Low |
| Payout request validation | Negative amount rejected | P1 | Unit | High |
| Leaderboard | `GET /drivers/leaderboard` returns leaderboard JSON, not 404 from `findOne("leaderboard")` | P1 | API | High — **blocked until route order fixed** (see `TECH_DEBT_AND_RECOMMENDATIONS.md`) |

### Documents

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Upload oversize / bad mime | 400 | P0 | API | High |
| Admin approve/reject | Status + optional reason | P0 | Integration | Medium |

### Admin

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Pending queues | Only PENDING items | P1 | Integration | Medium |
| Reports | Pagination + date filters if added | P2 | Manual | Low |

### Surge & promo

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Preview matches rule engine | Deterministic output | P1 | Unit | High |
| Promo validate invalid code | Clear error | P1 | Unit | High |

### Notifications & support

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Inbox pagination | Stable ordering | P2 | API | Medium |
| Ticket create/list scoped | User sees only own | P0 | Integration | High |
| FAQ `GET` with customer token | 200 (current behavior) | P2 | API | Low |

### Firebase

| Scenario | Expected | Priority | Level | Automation |
|----------|----------|----------|-------|------------|
| Register token persists on user | `fcmToken` saved | P1 | Integration (mock FB) | Medium |
| Send-push abuse | Rate limit or ADMIN-only | P0 | Security | Manual first |

---

## Manual QA scenarios (release checklist)

1. Fresh install → splash → login → customer home stitch loads.
2. Driver login → dashboard; toggle online (*if wired*).
3. Create delivery (Postman or app) → second device as driver sees offer (*WS*).
4. Complete delivery → customer can rate.
5. Admin verifies pending driver → driver gains `isVerified` in profile.
6. Offline / airplane mode → app shows network error without crash (*Flutter*).
7. Arabic locale → RTL layout sanity on non-Stitch screens.

---

## Edge cases & failures

- MongoDB down → `GET /health` fails; app shows degraded state.
- Large product images → catalog performance.
- Concurrent accept on same delivery → only one succeeds (*verify* `delivery-matching.service.ts`).

---

## Performance & security checks

- Load test `GET /catalog/products` with filters.
- JWT brute-force: throttling effectiveness.
- Static analysis: `flutter analyze`, `npm run lint` (already in CI).

---

## Automation order (suggested)

1. Auth + role matrix (supertest).
2. Orders/deliveries ownership tests.
3. Catalog read + admin write smoke.
4. Cost calculator + promo unit tests (already partial coverage).
5. Flutter: `AuthService` + `ApiService` unit tests with mocked `http`.
