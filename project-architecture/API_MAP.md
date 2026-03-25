# API map

**Base URL**: no API version prefix. **Swagger UI**: `GET /api` (Swagger setup in `backend/src/main.ts`).  
**Auth column**: `Public` = no JWT; `JWT` = `JwtAuthGuard`; roles from `@Roles()` where set; if guard applies but no `@Roles`, marked **JWT (any role)**.

---

## Auth (`backend/src/auth/auth.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/auth/register/customer` | Register customer, returns JWT | Public |
| POST | `/auth/register/driver` | Register driver + driver profile, returns JWT | Public |
| POST | `/auth/register` | Deprecated customer register | Public |
| POST | `/auth/login` | Login (email or phone + password) | Public |

---

## Users (`backend/src/users/users.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/users/me` | Current user profile (no password) | JWT (any) |
| PATCH | `/users/me` | Update profile | JWT (any) |
| PATCH | `/users/me/password` | Change password | JWT (any) |
| PATCH | `/users/me/preferences` | Update preferences | JWT (any) |
| GET | `/users/me/preferences` | Get preferences | JWT (any) |
| GET | `/users/favorites` | List favorite products | JWT (any) |
| POST | `/users/favorites/:productId` | Add favorite | JWT (any) |
| DELETE | `/users/favorites/:productId` | Remove favorite | JWT (any) |
| DELETE | `/users/me` | Delete account | JWT (any) |
| GET | `/users/debug` | List users summary | JWT **ADMIN** |

---

## User addresses (`backend/src/users/addresses.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/users/addresses` | List addresses | JWT (any) |
| POST | `/users/addresses` | Create address | JWT (any) |
| GET | `/users/addresses/:id` | Get one | JWT (any) |
| PATCH | `/users/addresses/:id` | Update | JWT (any) |
| PATCH | `/users/addresses/:id/set-default` | Set default | JWT (any) |
| DELETE | `/users/addresses/:id` | Delete | JWT (any) |

---

## Motorcycles (`backend/src/motorcycles/motorcycles.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/motorcycles` | Create | JWT **ADMIN, DRIVER** |
| GET | `/motorcycles` | List all | JWT (any) |
| GET | `/motorcycles/:id` | Get one | JWT (any) |
| PATCH | `/motorcycles/:id` | Update | JWT **ADMIN, DRIVER** |
| DELETE | `/motorcycles/:id` | Delete | JWT **ADMIN** |

---

## Drivers (`backend/src/drivers/drivers.controller.ts`)

| Method | Path | Purpose | Auth / roles |
|--------|------|---------|----------------|
| POST | `/drivers` | Create driver profile | JWT (no `@Roles` on method) |
| GET | `/drivers` | List all drivers | JWT **ADMIN** |
| GET | `/drivers/:id` | Get by id | JWT (no `@Roles`) |
| GET | `/drivers/user/:userId` | Get by user id | JWT (no `@Roles`) |
| PATCH | `/drivers/:id/availability` | Set availability | JWT (no `@Roles`) |
| PATCH | `/drivers/:id/motorcycle` | Link motorcycle | JWT (no `@Roles`) |
| PATCH | `/drivers/:id/rating` | Update rating | JWT (no `@Roles`) |
| POST | `/drivers/:id/deliveries/complete` | Increment delivery count | JWT (no `@Roles`) |
| POST | `/drivers/:id/documents` | Upload doc metadata | JWT (no `@Roles`) |
| PATCH | `/drivers/:id/documents` | Update documents | JWT (no `@Roles`) |
| PATCH | `/drivers/:id/verification` | Admin verify | JWT **ADMIN** |
| GET | `/drivers/:id/earnings` | Earnings breakdown | JWT **DRIVER, ADMIN** |
| GET | `/drivers/:id/performance` | Performance metrics | JWT **DRIVER, ADMIN** |
| GET | `/drivers/:id/deliveries/history` | Delivery history | JWT **DRIVER, ADMIN** |
| PATCH | `/drivers/:id/location` | GPS update | JWT **DRIVER** |
| GET | `/drivers/leaderboard` | Top drivers | JWT (no `@Roles`) |
| POST | `/drivers/:id/earnings/withdraw` | Payout request | JWT **DRIVER** |
| GET | `/drivers/:id/earnings/history` | Payout history | JWT **DRIVER, ADMIN** |
| GET | `/drivers/:id/schedule` | Get schedule | JWT **DRIVER, ADMIN** |
| PATCH | `/drivers/:id/schedule` | Update schedule | JWT **DRIVER** |

*Bug risk (verified by route order in source):* `GET /drivers/leaderboard` is declared **after** `GET /drivers/:id`. In NestJS, **`/drivers/leaderboard` is likely handled as `:id = "leaderboard"`** (wrong handler). **Fix:** declare `Get('leaderboard')` (and `Get('user/:userId')`) **before** `Get(':id')` in `drivers.controller.ts`.

---

## Deliveries (`backend/src/deliveries/deliveries.controller.ts`)

| Method | Path | Purpose | Auth / roles |
|--------|------|---------|----------------|
| POST | `/deliveries` | Create delivery | JWT **CUSTOMER** |
| GET | `/deliveries` | List for current user | JWT (no `@Roles`) |
| GET | `/deliveries/driver/available` | Pool for drivers | JWT **DRIVER** |
| GET | `/deliveries/driver/active` | Driver’s active | JWT **DRIVER** |
| GET | `/deliveries/:id` | Get one | JWT (no `@Roles`) |
| PATCH | `/deliveries/:id/status` | Update status | JWT **DRIVER** |
| POST | `/deliveries/:id/calculate-cost` | Cost estimate | JWT (no `@Roles`) |
| POST | `/deliveries/:id/accept` | Driver accept | JWT **DRIVER** |
| POST | `/deliveries/:id/start` | Start | JWT **DRIVER** |
| POST | `/deliveries/:id/complete` | Complete | JWT **DRIVER** |
| POST | `/deliveries/:id/cancel` | Cancel | JWT (no `@Roles`) |
| POST | `/deliveries/:id/tip` | Add tip | JWT **CUSTOMER** |
| POST | `/deliveries/:id/rate` | Rate delivery | JWT **CUSTOMER** |

---

## Orders (`backend/src/orders/orders.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/orders` | Create order | JWT (no `@Roles`) |
| GET | `/orders` | My orders | JWT (no `@Roles`) |
| GET | `/orders/history` | Same as list (*observed*) | JWT (no `@Roles`) |
| GET | `/orders/:id` | Get one | JWT (no `@Roles`) |
| PATCH | `/orders/:id/status` | Update status | JWT **ADMIN** |
| POST | `/orders/:id/reorder` | Reorder | JWT (no `@Roles`) |

---

## Catalog (`backend/src/catalog/catalog.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/catalog/categories` | List categories | Public |
| GET | `/catalog/merchants` | List active merchants (id, name, region) | JWT **ADMIN** |
| GET | `/catalog/products` | List/filter products | Public |
| GET | `/catalog/products/search` | Search | Public |
| GET | `/catalog/products/:id` | Product detail | Public |
| GET | `/catalog/products/:id/related` | Related products | Public |
| POST | `/catalog/products` | Create product | JWT **ADMIN** |
| PATCH | `/catalog/products/:id` | Update product | JWT **ADMIN** |
| DELETE | `/catalog/products/:id` | Delete product | JWT **ADMIN** |
| POST | `/catalog/categories` | Create category | JWT **ADMIN** |
| PATCH | `/catalog/categories/:id` | Update category | JWT **ADMIN** |
| DELETE | `/catalog/categories/:id` | Delete category | JWT **ADMIN** |

---

## Documents (`backend/src/documents/documents.controller.ts`)

| Method | Path | Purpose | Auth / roles |
|--------|------|---------|----------------|
| POST | `/documents/upload` | Multipart upload | JWT **DRIVER** |
| GET | `/documents/my-documents` | My docs | JWT (no `@Roles`) |
| GET | `/documents/stats` | Stats for user | JWT (no `@Roles`) |
| GET | `/documents/pending` | Pending queue | JWT **ADMIN** |
| GET | `/documents/:id` | Get by id | JWT (no `@Roles`) |
| PATCH | `/documents/:id/status` | Admin status | JWT **ADMIN** |
| DELETE | `/documents/:id` | Delete (owner or admin) | JWT (no `@Roles`; service checks owner) |

---

## Admin (`backend/src/admin/admin.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/admin/dashboard` | Dashboard aggregate | JWT **ADMIN** |
| GET | `/admin/drivers/pending` | Pending drivers | JWT **ADMIN** |
| GET | `/admin/documents/pending` | Pending documents | JWT **ADMIN** |
| POST | `/admin/drivers/:driverId/verify` | Verify driver | JWT **ADMIN** |
| POST | `/admin/drivers/:driverId/reject` | Reject driver | JWT **ADMIN** |
| PATCH | `/admin/documents/:documentId/status` | Document decision | JWT **ADMIN** |
| GET | `/admin/deliveries/stats` | Delivery stats | JWT **ADMIN** |
| GET | `/admin/users/stats` | User stats | JWT **ADMIN** |
| GET | `/admin/analytics/fraud` | Fraud analytics | JWT **ADMIN** |
| GET | `/admin/analytics/revenue` | Revenue analytics | JWT **ADMIN** |
| GET | `/admin/drivers/:driverId/activity` | Driver activity | JWT **ADMIN** |
| GET | `/admin/system/health` | System health | JWT **ADMIN** |
| GET | `/admin/reports/deliveries` | Deliveries report | JWT **ADMIN** |
| GET | `/admin/reports/drivers` | Drivers report | JWT **ADMIN** |

---

## Surge (`backend/src/surge/surge.controller.ts`, `surge-pricing.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/surge-rules` | Create rule | JWT **ADMIN** |
| GET | `/surge-rules` | List rules | JWT **ADMIN** |
| PATCH | `/surge-rules/:id` | Update | JWT **ADMIN** |
| POST | `/surge-rules/:id/toggle` | Enable/disable | JWT **ADMIN** |
| DELETE | `/surge-rules/:id` | Delete | JWT **ADMIN** |
| POST | `/surge-rules/preview` | Preview | JWT **ADMIN** |
| GET | `/surge-pricing/current` | Current surge | JWT **CUSTOMER, DRIVER, ADMIN** |

---

## Promo codes (`backend/src/promo-codes/promo-codes.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/promo-codes/validate` | Validate code | JWT **CUSTOMER, ADMIN** |
| POST | `/promo-codes/apply` | Apply to total | JWT **CUSTOMER, ADMIN** |

---

## Recommendations (`backend/src/recommendations/recommendations.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/recommendations` | User recommendations | JWT (any — no `@Roles`) |
| GET | `/products/:id/fbt` | Frequently bought together | JWT (any — no `@Roles`) |

---

## Notifications

**Preferences** — `backend/src/notifications/notifications.controller.ts`, `@Controller('notification-preferences')`

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/notification-preferences` | Get prefs | JWT (any) |
| POST | `/notification-preferences` | Update prefs | JWT (any) |

**Inbox** — `backend/src/notifications/notification-inbox.controller.ts`, `@Controller('notifications')`

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/notifications` | Paginated inbox | JWT (any) |
| POST | `/notifications/:id/read` | Mark read | JWT (any) |
| POST | `/notifications/read-all` | Mark all read | JWT (any) |
| DELETE | `/notifications/:id` | Delete | JWT (any) |

---

## Support (`backend/src/support/support.controller.ts`, `@Controller()`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/support/tickets` | Create ticket | JWT (any) |
| GET | `/support/tickets` | My tickets | JWT (any) |
| GET | `/support/tickets/:id` | Ticket detail | JWT (any) |
| PATCH | `/admin/support/tickets/:id/status` | Admin update status | JWT **ADMIN** |
| GET | `/admin/support/tickets` | All tickets | JWT **ADMIN** |
| POST | `/feedback` | Submit feedback | JWT (any) |
| GET | `/faqs` | List FAQs | JWT (any) *class-level guard* |
| POST | `/faqs` | Create FAQ | JWT **ADMIN** |

---

## Firebase (`backend/src/firebase/firebase.controller.ts`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| POST | `/firebase/register-token` | Save FCM token on user | JWT (any) |
| POST | `/firebase/send-push` | Send test push | JWT (any) |

---

## Health / system (`backend/src/health/`)

| Method | Path | Purpose | Auth |
|--------|------|---------|------|
| GET | `/health` | Mongo ping (Terminus), `@SkipThrottle` | Public |
| GET | `/system/version` | Version info | Public (*verify* response shape in `system.controller.ts`) |

---

## WebSocket (not REST)

| Namespace | Handshake | Events (subscribe) | Server emits |
|-----------|-----------|--------------------|--------------|
| `/delivery` | JWT in `auth.token` or `query.token` | `subscribeToDelivery`, `unsubscribeFromDelivery`, `updateLocation` (driver) | `delivery_status_update`, `new_delivery`, `delivery_assigned`, `driver_assigned`, `driver_status_update`, `location_update` |

*Source:* `backend/src/websocket/delivery.gateway.ts`.

---

## Payload / response notes

- Standard pattern: JSON bodies validated with `class-validator` DTOs where present.
- Errors: global `AllExceptionsFilter` (`backend/src/common/filters/all-exceptions.filter.ts`).
- **Multipart**: `POST /documents/upload` — field `file` + `documentType` (`documents.controller.ts`).
